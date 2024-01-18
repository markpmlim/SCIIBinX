//
//  BSCOperation.m
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import "BSCOperation.h"
#import "FileWrapper.h"

// The Main Window Controller will be observing these.
NSString *const cancelledOperationsNote = @"cancelledOperationsNote";
NSString *const finishedOperationsNote = @"finishedOperationsNote";

@implementation BSCOperation

- (id)initWithPaths:(NSArray *)paths
{
    self = [super init];
    if (self)
    {
        pathNames = [paths retain];
    }
    return self;    
}

-(void) dealloc {
    if (pathNames != nil)
    {
        [pathNames release];
        pathNames = nil;
    }

    [super dealloc];
}

/*
 For each BSC/BSQ file, we verify that it has at least 1 BINSCII segment. If yes,
 we proceed to decode the entire file. If there are more than 1 BINSCII segment
 the "Unpack" method of the decoder will deal with them.
 */
- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *path in pathNames)
    {
        if ([self isCancelled])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:cancelledOperationsNote
                                                                object:self
                                                              userInfo:nil];
            goto bailOut;
        }
        
        BOOL result = YES;              // assume all will be ok.
        NSError *outErr = nil;
        
        FileWrapper *fileWrapper = [[[FileWrapper alloc] initWithPath:path
                                                                error:&outErr] autorelease];
        if (outErr == nil)
        {
            if ([fileWrapper verifyHeader:&outErr])
            {
                if ([fm fileExistsAtPath:[fileWrapper pathOfDecodedFile]])
                {
                    // The only check possible is the expected file length against
                    // the actual file length of the decoded file.
                    NSUInteger expectedSize = [fileWrapper decodedFileLength];
                    NSDictionary *fileAttr = [fm attributesOfItemAtPath:[fileWrapper pathOfDecodedFile]
                                                                  error:&outErr];
                    if (outErr == nil) 
                    {
                        NSUInteger actualSize = [fileAttr fileSize];
                        if (actualSize != expectedSize)
                        {
                            NSLog(@"The expected file size of the decoded file of %@ does not match its actual size", path);
                            continue;       // try next file
                        }
                    }
                    else
                    {
                        NSLog(@"%@ returned for %@", outErr, [fileWrapper pathOfDecodedFile]);
                        continue;       // try next file
                    }
                }
                else
                {
                    // We create a zerored file for output.
                    NSUInteger fileLen = [fileWrapper decodedFileLength];
                    NSMutableData *zeroData = [NSMutableData dataWithLength:fileLen];
                    result = [zeroData writeToFile:[fileWrapper pathOfDecodedFile]
                                        atomically:NO];
                    if (result == NO) 
                    {
                        NSLog(@"Can't create the initial zeroed decoded file of %@", path);
                        continue;       // try next file
                    }
                }
                
                // If we reach here, we can proceed to decode the file
                if ([fileWrapper unpack:&outErr] == YES)
                {
                    // The (segment) file has been decoded successfully.
                    NSDictionary *fileAttr = [fileWrapper attributesOfDecodedFile]; 
                    NSString *destPath = [fileWrapper pathOfDecodedFile];
                    // In case, the encoded file has a single segment.
                    [fm setAttributes:fileAttr
                         ofItemAtPath:destPath
                                error:&outErr];
                    // assume no problems
                }
                else 
                {
                    NSLog(@"%@ returned while unpacking %@", outErr, path);
                    continue;       // try next file
                }
            }
            else 
            {
                NSLog(@"%@ returned while verifying %@", outErr, path);
                continue;           // try next file
            }
        }
        else
        {
            NSLog(@"%@ returned for file %@:", outErr, path);
            continue;               // try next file
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:finishedOperationsNote
                                                        object:self
                                                      userInfo:nil];
bailOut:
    [pool drain];

}
@end
