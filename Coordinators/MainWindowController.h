//
//  MainWindowController.h
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileWrapper;

@interface MainWindowController : NSWindowController
{
    NSWindow                *window;
    NSOperationQueue        *bscQueue;
    NSProgressIndicator     *progressIndicator;
    NSButton                *stopButton;
}

@property (assign) IBOutlet NSWindow            *window;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton            *stopButton;
@property (retain)          NSOperationQueue    *bscQueue;

- (IBAction)cancel:(id)sender;
- (BOOL)process:(NSArray *)listOfPaths;

@end
