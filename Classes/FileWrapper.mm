//
//  FileWrapper.m
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import "FileWrapper.h"
#import "BSCError.h"

#include "decoder.hpp"
#include "ErrorCodes.h"

@implementation FileWrapper

@synthesize bsqFile;
@synthesize destFolderName;
@synthesize pathName;

// We retain the flexibility to set the destination folder name separately
// via a "Save As..." dialog box. Use an additional parameter to this method.
// The parameter "path" is the pathname of the BSC/BSQ file.
- (id)initWithPath:(NSString *)path
             error:(NSError **)errorPtr
{
    if (errorPtr != nil)
    {
        *errorPtr = nil;
    }
    self = [super init];
    if (self)
    {
        // KIV. set "destFolderName" to user preferred folder.
        destFolderName = [[path stringByDeletingLastPathComponent] retain];
        //printf("%s\n", [destFolderName cStringUsingEncoding:NSMacOSRomanStringEncoding]);
        pathName = [path retain];
        //printf("%s\n", [pathName cStringUsingEncoding:NSMacOSRomanStringEncoding]);
        fileName = [[path lastPathComponent] retain];

        bsqFile = (id)new BinScii();
        BSErrorCodes errCode = kBSNoError;
        BOOL isOpen;
        isOpen = ((BinScii *)bsqFile)->Open([path cStringUsingEncoding:NSASCIIStringEncoding], errCode);
        if (isOpen != YES)
        {
            *errorPtr = [BSCError errorWithCode:errCode];
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    //printf("deallocating file wrapper object\n");
    delete (BinScii*)bsqFile;   // the destructor  will be called!
    if (destFolderName != nil)
    {
        [destFolderName release];
    }
    if (pathName != nil)
    {
        [pathName release];
    }
    if (fileName != nil)
    {
        [fileName release];
    }
    [super dealloc];
}

/*
 After a call to the C++ object's Verify method, information on the decoded file
 will be available. This method could be used by other Objective-C methods whenever
 information on the decoded file is required e.g. the file name of the decoded file
 can be obtained w/o unpacking the body of the segment(s) of the encoded file.
 In fact, every segment of the encoded file has the same file information.
 This method can also be used to determine if a file has an embedded BINSCII segment. 
 */
- (BOOL)verifyHeader:(NSError **)errorPtr;
{
    if (errorPtr != nil)
    {
        *errorPtr = nil;
    }

    BSErrorCodes errCode = kBSNoError;
    BOOL isHeaderOK = ((BinScii*)self.bsqFile)->Verify(errCode);
    if (isHeaderOK)
    {
        return YES;
    }
    else
    {
        // All returned errors are logged in the file:
        // ~/Library/Application Support/SCIIBinX/messages.log
        // See AppDelegate.m for further details.
        *errorPtr = [BSCError errorWithCode:errCode];
        return NO;
    }
}

/*
 This method will return the decoded file's info besides unpacking and writing
 its contents in the same folder of the BSQ wrapper.
 KIV. Re-write the decoder method Unpack not return the decoded file's info.
 In which case, it becomes mandatory to send the message verifyHeader to a
 BINSCII object before sending the message Unpack. Use a flag within the C++
 object to indicate that the info is available.
 Not feasible because the decoder has to deal with interpersed text.
 */
- (BOOL) unpack:(NSError **)errorPtr
{
    if (errorPtr != nil)
    {
        *errorPtr = nil;
    }

    BSErrorCodes errCode = kBSNoError;
    if (((BinScii*)self.bsqFile)->Unpack(errCode))
    {
        return YES;
    }
    else
    {
        // Assumes the error code returned by the decoder is transmitted up.
        *errorPtr = [BSCError errorWithCode:errCode];
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
- (NSDictionary *)getHfsCodesForFileType:(OSType)fileType
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
    {   // For the rest, pass the task to the help method
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
- (NSDictionary *)attributesOfDecodedFile;
{
    FileAttributes attr;

    ((BinScii*)self.bsqFile)->GetAttributes(attr);
    NSDate *creationDateTime = [NSDate dateWithTimeIntervalSince1970:attr.creationDateTime];
    NSDate *modificationDateTime = [NSDate dateWithTimeIntervalSince1970:attr.modificationDateTime];
    // Convert prodos file/aux type
    NSDictionary *fileAttr = [self getHfsCodesForFileType:attr.fileType
                                               andAuxType:attr.auxType];
    // The following are currently unused.
    NSNumber *accessCode = [NSNumber numberWithUnsignedInt:attr.accessMode];
    NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:attr.fileSize];
    // Add the creation and modification dates and times.
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    [newDict addEntriesFromDictionary:fileAttr];                                              
    [newDict setObject:creationDateTime
                forKey:NSFileCreationDate];
    [newDict setObject:modificationDateTime
                forKey:NSFileModificationDate];
/*
    [newDict setObject:fileSize
                forKey:NSFileSize];
 */
    return newDict;
}

// Returns the path name of the encoded file; the "verifyHeader"
// or unpack method of this class must be called first.
- (NSString *) pathOfDecodedFile
{
    const char *destPath = ((BinScii*)self.bsqFile)->GetDestPathname();
    return [NSString stringWithCString:destPath
                              encoding:NSASCIIStringEncoding];
}

- (NSUInteger)decodedFileLength
{
    FileAttributes attr;
    ((BinScii*)self.bsqFile)->GetAttributes(attr);
    return attr.fileSize;
}

@end
