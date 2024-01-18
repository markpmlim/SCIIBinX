#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface,
								 QLThumbnailRequestRef thumbnail,
								 CFURLRef url,
								 CFStringRef contentTypeUTI,
								 CFDictionaryRef options,
								 CGSize maxSize)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *path = [(NSURL *)url path];
	// We need to change to uppercase unlike instances of NSOpenPanel/NSSavePanel.
	NSString *fileExt = [[path pathExtension] uppercaseString];
	if ([fileExt isEqualToString:@"BSC"] ||
		[fileExt isEqualToString:@"BSQ"])
	{
		NSString *iconPath = [[NSBundle bundleWithIdentifier: @"com.incrementalinnovation.QuickLookBSQ"] pathForResource:@"sciibin"
																												  ofType:@"png"];
		if (iconPath == NULL)
		{
			goto bailOut;
		}
		
		NSData *imageData = [NSData dataWithContentsOfFile:iconPath];
		if (imageData != nil)
		{
			NSDictionary *properties = [NSDictionary dictionaryWithObject:@"public.png"
																   forKey:(NSString *)kCGImageSourceTypeIdentifierHint];
			// working for 16x16: set QLThumbnailMinimumSize in info.plist to 16
			QLThumbnailRequestSetImageWithData(thumbnail,
											   (CFDataRef)imageData,
											   (CFDictionaryRef)properties);
		}
	}
bailOut:
	[pool drain];
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
