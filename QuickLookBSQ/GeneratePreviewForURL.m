#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import "BSQArchive.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */
// "contentTypeUTI" is passed as a file extension (in uppercase)
OSStatus GeneratePreviewForURL(void *thisInterface,
							   QLPreviewRequestRef preview,
							   CFURLRef url,
							   CFStringRef contentTypeUTI, 
							   CFDictionaryRef options)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSString *utiTypeStr = (NSString *)contentTypeUTI;
	//NSLog(@"IIGS UTI:%@", utiTypeStr);

	//NSString *path = [(NSURL *)url path];
	// We need to change to uppercase unlike instances of NSOpenPanel/NSSavePanel.
	//NSString *fileExt = [[path pathExtension] uppercaseString];
	//NSLog(@"path to file:%@ & extension:%@", (NSURL *)url, fileExt);
	
	BSQArchive *bsqArchive = [[[BSQArchive alloc] initWithURL:(NSURL *)url] autorelease];
	if (bsqArchive != nil)
	{
		NSDictionary *attrs = [bsqArchive attributes];
		u_int32_t fileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
		NSString *fileSizeStr = [NSString stringWithFormat:@"%u", fileSize];

		#define twelveK	12288
		u_int32_t numSegments = 0;
		while (fileSize > twelveK*numSegments) {
			numSegments++;
		}
		NSString *numSegmentsStr = [NSString stringWithFormat:@"%u", numSegments];

		NSDate *fileCreationDate = [attrs objectForKey:NSFileCreationDate];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		NSString *creationDateStr = [dateFormatter stringFromDate:fileCreationDate];
		NSDate *fileModificationDate = [attrs objectForKey:NSFileModificationDate];
		NSString *modificationDateStr = [dateFormatter stringFromDate:fileModificationDate];

		OSType hfsTypeCode = [[attrs objectForKey:NSFileHFSTypeCode] unsignedLongValue];
		u_int32_t pdosFileType = (hfsTypeCode & 0x00ff0000) >> 16;
		u_int32_t pdosFileAuxType = hfsTypeCode & 0x0000ffff;
		NSString *fileTypeStr = [NSString stringWithFormat:@"$%02X", pdosFileType];
		NSString *auxTypeStr = [NSString stringWithFormat:@"$%04X", pdosFileAuxType];

		// Load the html template.
		NSBundle *bundle = [NSBundle bundleForClass:[BSQArchive class]];
		NSString *templatePath = [bundle pathForResource:@"template"
												  ofType:@"html"];
		NSError *err = nil;
		NSString *htmlDoc = [NSString stringWithContentsOfFile:templatePath
													  encoding:NSUTF8StringEncoding
														 error:&err];
		if (err != nil)
		{
			goto bailOut;
		}
		// Modify the values
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__File Name__"
										   withString:[bsqArchive fileName]];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__File Size__"
										   withString:fileSizeStr];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__Number of Segments__"
													 withString:numSegmentsStr];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__Creation Date__"
													 withString:creationDateStr];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__Modification Date__"
													 withString:modificationDateStr];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__File Type__"
													 withString:fileTypeStr];
		htmlDoc = [htmlDoc stringByReplacingOccurrencesOfString:@"__File Aux Type__"
													 withString:auxTypeStr];

		// Load the css & image to be attached to the HTML object.
		NSString *cssPath = [bundle pathForResource:@"style"
											 ofType:@"css"];
		NSData *cssData = [NSData dataWithContentsOfFile:cssPath];
		NSString *imgPath = [bundle pathForResource:@"sciibin"
											 ofType:@"png"];
		NSData *imgData = [NSData dataWithContentsOfFile:imgPath];

		// Set up the dictionaries.
		NSMutableDictionary *cssProps = [[[NSMutableDictionary alloc] init] autorelease];
		[cssProps setObject:@"text/css"			// mime type
					 forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
		[cssProps setObject:cssData
					 forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];

		NSMutableDictionary *imgProps = [[[NSMutableDictionary alloc] init] autorelease];
		[imgProps setObject:@"image/png"			// mime type
					 forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
		[imgProps setObject:imgData
					 forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];

		// Setup the dictionary
		NSMutableDictionary *properties = [[[NSMutableDictionary alloc] init] autorelease];
		[properties setObject:@"UTF-8"
					   forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
		[properties setObject:@"text/html"
					   forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
		[properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   cssProps, @"style.css",
								   imgProps, @"scii.png",
								   nil]
					   forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
		QLPreviewRequestSetDataRepresentation(preview,
											  (CFDataRef)[htmlDoc dataUsingEncoding:NSUTF8StringEncoding],
											  kUTTypeHTML,
											  (CFDictionaryRef)properties);
	}
bailOut:
	[pool drain];
	return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
