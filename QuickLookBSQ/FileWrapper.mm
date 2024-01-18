//
//  FileWrapper.m
//  QuickLookBSQ
//
//  Created by mark lim on 12/28/13.
//  Copyright 2013 IncrementalInnovation.com. All rights reserved.
//

#import "FileWrapper.h"

#include "decoder.hpp"
#include "ErrorCodes.h"

@implementation FileWrapper

@synthesize bsqFile;

// We retain the flexibility to set the destination folder name separately
// via a "Save As..." dialog box. Use an additional parameter to this method.
// The parameter "path" is the pathname of the encoded file.
- (id)initWithPath:(NSString *)path
{
	self = [super init];
    if (self)
	{
		bsqFile = (id)new BinScii();
		BSErrorCodes errCode = kBSNoError;
		BOOL isOpen;
		isOpen = ((BinScii *)bsqFile)->Open([path cStringUsingEncoding:NSASCIIStringEncoding], errCode);
		if (isOpen != YES)
		{
			self = nil;
		}
    }
    return self;
}

- (void)dealloc
{
	delete (BinScii*)bsqFile;
	[super dealloc];
}

/*
 After a call to the C++ object's Verify method, information on the decoded file
 will be available. This method could be used by other Objective-C methods whenever
 information on the decoded file is required e.g. the file name of the decoded file
 can be obtained w/o unpacking the body of the segment(s) of the encoded file.
 In fact, every segment of the encoded file 
 */
- (BOOL)verifyHeader
{
	BSErrorCodes errCode = kBSNoError;
	BOOL headerOK = ((BinScii*)self.bsqFile)->Verify(errCode);
	if (headerOK)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

#pragma helper methods to convert prodos file/aux types
/*
 Convert a ProDOS file type and aux type to a MacOS hfsTypeCode.
 The general case is done first; it covers the case $B3, $DByz. For specific
 cases, the initial typeCode object will be replaced.
 */
- (NSNumber*)getTypeCodeForFileType:(OSType)fileType
                         andAuxType:(OSType)auxType
{
	NSNumber *typeCode;
	OSType hfsTypeCode;
	
	hfsTypeCode = 0x70000000 + (fileType << 16) + auxType;
	typeCode = [NSNumber numberWithUnsignedInt:hfsTypeCode];
	switch (fileType)
	{
		case 0x00:
			// checked
			if (auxType == 0x0000)
				typeCode = [NSNumber numberWithUnsignedInt:'BINA'];
			break;
		case 0x04:
			// checked
			if (auxType == 0x0000)
				typeCode = [NSNumber numberWithUnsignedInt:'TEXT'];
			break;
		case 0xb3:
			// checked
			if ((auxType & 0xff00) != 0xdb00)
			{
				typeCode = [NSNumber numberWithUnsignedInt:'PS16'];
			}
			break;
		case 0xd7:
			// checked
			if (auxType == 0x0000)
				typeCode = [NSNumber numberWithUnsignedInt:'MIDI'];
			break;
		case 0xd8:
			// both checked
			if (auxType == 0x0000)
				typeCode = [NSNumber numberWithUnsignedInt:'AIFF'];
			if (auxType == 0x0001)
				typeCode = [NSNumber numberWithUnsignedInt:'AIFC'];
			break;
		case 0xff:
			// checked
			typeCode = [NSNumber numberWithUnsignedInt:'PSYS'];
			break;
		default:
			break;
	}
	return typeCode;
}

// Get the hfs filetype and creator codes of the file; 0xe0/0x0005 is done
//  separately from the others because it too specific.
-(NSDictionary *) getHfsCodesForFileType:(OSType)fileType
							  andAuxType:(OSType)auxType
{
	NSNumber* typeCode;
	NSNumber* creatorCode;
	if (fileType == 0xe0 && auxType == 0x0005)
	{
		// checked
		typeCode = [NSNumber numberWithUnsignedInt:'dImg'];
		creatorCode = [NSNumber numberWithUnsignedInt:'dCpy'];
	}
	else
	{	// For the rest, pass the task to the help method
		typeCode = [self getTypeCodeForFileType:fileType
									 andAuxType:auxType];
		creatorCode = [NSNumber numberWithUnsignedInt:'pdos'];
	}
	NSDictionary *codesDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   typeCode, NSFileHFSTypeCode,
								   creatorCode, NSFileHFSCreatorCode,
								   nil];
	return codesDict;
}

/*
 This method sends a message to the C++ BINSCII object to return a custom record
 of attributes of the  file. It transforms these attributes into a form
 acceptable to MacOSX.
 NB. accessMode and fileSize are not used. We can't set a file's size in Obj-C
 KIV. To use the accessMode to set the file's r/w mode on MacOSX; ignore some
 of the other bits.
 */
- (NSDictionary *)attributesOfDecodedFile
{
	FileAttributes attr;

	((BinScii*)self.bsqFile)->GetAttributes(attr);
	NSDate *creationDateTime = [NSDate dateWithTimeIntervalSince1970:attr.creationDateTime];
	NSDate *modificationDateTime = [NSDate dateWithTimeIntervalSince1970:attr.modificationDateTime];
	// Convert prodos file/aux type
	NSDictionary *fileAttr = [self getHfsCodesForFileType:attr.fileType
											   andAuxType:attr.auxType];
	NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:attr.fileSize];
	// this is unused.
	//NSNumber *accessCode = [NSNumber numberWithUnsignedInt:attr.accessMode];
	// Add the creation and modification dates and times
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:5];
	[newDict addEntriesFromDictionary:fileAttr];											  
	[newDict setObject:creationDateTime
				forKey:NSFileCreationDate];
	[newDict setObject:modificationDateTime
				forKey:NSFileModificationDate];
	[newDict setObject:fileSize
				forKey:NSFileSize];
	return newDict;
}

// Returns the path name of the encoded file; the verifyHeader/Unpack
// methods must be called first.
- (NSString *)pathOfDecodedFile
{
	const char *destPath = ((BinScii*)self.bsqFile)->GetDestPathname();
	return [NSString stringWithCString:destPath
							  encoding:NSASCIIStringEncoding];
}


@end
