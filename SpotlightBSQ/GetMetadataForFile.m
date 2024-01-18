#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#import <Cocoa/Cocoa.h>
#import "BSQArchive.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForURL function
  
   Implement the GetMetadataForURL function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update schema.xml and schema.strings files
   
   The schema.xml should be added whenever you need attributes displayed in 
   Finder's get info panel, or when you have custom attributes.  
   The schema.strings should be added whenever you have custom attributes. 
 
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */
// Problem with Finder's Get Info Panel.
// "contentTypeUTI" is passed with the value "appleii.binscii-archive"
Boolean GetMetadataForFile(void *thisInterface, 
						   CFMutableDictionaryRef attributes, 
						   CFStringRef contentTypeUTI,
						   CFStringRef pathToFile)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL result = NO;
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
	//NSLog(@"uti str: %@", (NSString *)contentTypeUTI);
	NSString *path = (NSString *)pathToFile;
	NSURL *url = [NSURL fileURLWithPath:path];
	BSQArchive *bsqArchive = [[[BSQArchive alloc] initWithURL:(NSURL *)url] autorelease];

	if (bsqArchive != nil)
	{
		NSMutableDictionary *dict = (NSMutableDictionary *)attributes;
		NSDictionary *attrs = [bsqArchive attributes];
		NSDate *modDate = [attrs objectForKey: NSFileModificationDate];
		NSString *itemName = [bsqArchive fileName];
		[dict setObject:modDate
				 forKey:@"com_incrementalinnovation_SCIIBinX_ItemModDate"];
		[dict setObject:itemName
				 forKey:@"com_incrementalinnovation_SCIIBinX_ItemName"];
		result = YES;
	}
bailOut:
	[pool drain];
    return result;
}
