//
//  MainWindowController.m
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import "MainWindowController.h"
#import "FileWrapper.h"
#import "BSCOperation.h"

// Comment out the macro if single secondary thread is preferred.
#define MULTITHREADED
@implementation MainWindowController

@synthesize window;
@synthesize progressIndicator;
@synthesize stopButton;
@synthesize bscQueue;

/*
 We need to keep track of the number of operations currently in the queue
 including those executing and pending.
 The NSOperationQueue method "operationCount" is for 10.6 or later.
 */
NSUInteger operationCount = 0;

- (void)awakeFromNib
{
    // Use a "cancel" button similar to Finder; needs more work; some attributes
    // eg Bordered is disabled are set in the nib file.
    NSImage *stopImage = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
    [stopButton setImage:stopImage];
    bscQueue = [[NSOperationQueue alloc] init];
    bscQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    //NSLog(@"register dragged types");
    // Inform the OS our window is able to handle the following drag types
    [[self window] registerForDraggedTypes:[NSArray arrayWithObjects:
                                                NSFilenamesPboardType,
                                                nil]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelFileOperations:)
                                                 name:cancelledOperationsNote
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finderFinishedOperations:)
                                                 name:finishedOperationsNote
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:cancelledOperationsNote
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:finishedOperationsNote
                                                  object:nil];
    if (bscQueue != nil)
    {
        [bscQueue release];
        bscQueue = nil;
    }
    [super dealloc];
}

#pragma mark Monitoring operations in the queue.
- (void)cancelFileOperations:(id)sender
{
    NSSound *glass = [NSSound soundNamed:@"Glass"];
    [glass play];
    [progressIndicator stopAnimation:self];
    operationCount = 0;
}

// There may be multiple drag-and-drops. The notification "finishedOperationsNote" is
// sent when an instance of NSOperation has finished decoding a particular set of files.
- (void)finderFinishedOperations:(id)sender
{
    NSSound *sosumi = [NSSound soundNamed:@"Sosumi"];
    [sosumi play];
    operationCount--;
    if (operationCount == 0)
    {
        [progressIndicator stopAnimation:self];
    }
}

// The extraction process is very fast; during testing it could be delayed
// to allow a circular progress indicator to be observed.
// This will cancel ALL operations currently executing and those that are
// in the queue.
- (IBAction)cancel:(id)sender
{
    NSSound *ping = [NSSound soundNamed:@"Ping"];
    [ping play];
    [bscQueue cancelAllOperations];
}

/*
 Check that each
 1) pathname has the correct extension(s), and
 2) none of them is a directory
 This is the first line of defence against illegal files being
 dragged and dropped onto the window.
 */

- (BOOL)checkFilenames:(NSArray *)listOfPaths
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isValid = NO;
    
    for (NSString* path in listOfPaths)
    {
        NSString *extension = [path pathExtension];
        BOOL isDir;

        if ([fm fileExistsAtPath:path
                    isDirectory:&isDir] & isDir)
        {
            NSLog(@"%@ is a folder", path);
            break;
        }
        if ([extension caseInsensitiveCompare:@"bsc"] == NSOrderedSame ||
            [extension caseInsensitiveCompare:@"bsq"] == NSOrderedSame)
        {
            isValid = YES;
        }
        else
        {
            isValid = NO;
            //NSLog(@"This file: %@ does not have the correct file extension.", path);
            break;
        }

    }
    return isValid;
}

/*
 The file wrapper object is an Objective-C object used to access the C++ object
 responsible for decoding the BSC/BSQ file. We must unpack the segment header
 first in order to get some of the decoded file's attributes.
 All error messages will be recorded in the logs.
 Select the "Logs" menu item "Display" to check if there are errors during
 file processing.
 */
- (BOOL)process:(NSArray *)listOfPaths
{
    [progressIndicator startAnimation:self];
#ifdef MULTITHREADED
    for (NSString *path in listOfPaths)
    {
        // Encapsulate each path in the list in an instance of NSArray and just pass
        // the file to an instance of BSCOperation.
        // The OS will decide which thread to use.
        NSArray *paths = [NSArray arrayWithObject:path];
        BSCOperation *fileOp = [[BSCOperation alloc] initWithPaths:paths];
        [bscQueue addOperation:fileOp];
        operationCount++;
        [fileOp release];
    } // for
#else
    // All the files in the list of pathnames will be processed on
    // the same secondary thread.
    BSCOperation *fileOp = [[BSCOperation alloc] initWithPaths:listOfPaths
                                                andDelegate:self];
    [bscQueue addOperation:fileOp];
    operationCount++;
    [fileOp release];
#endif
    return YES;
}

#pragma implementation of some methods to support drag and drop
/*
 These 3 methods are enough to get the list of paths dragged onto our window.
 Remember to create a WindowController object in the MainMenu.xib file
 and make it the window object's delegate.
 */
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationEvery;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    BOOL result = YES;
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSArray* files = [pboard propertyListForType:NSFilenamesPboardType];
        if ([self checkFilenames:files])
        {
            [self process:files];
        }
        else
        {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Either one of your file(s) does not have the correct file extension or it's a folder",
                                                                             @"Error")
                                             defaultButton:NSLocalizedString(@"OK",
                                                                             @"OK button")
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"Try again",
                                                                             @"Try Message")];

            NSInteger answer = [alert runModal];
            result = NO;
        }
    }
    else
    {
        result = NO;
    }
    return result;
}

// Clean up here (if any)
- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    //NSLog(@"conclude drag ops");
    NSPasteboard *pboard = [sender draggingPasteboard];
}

@end

