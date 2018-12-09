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
    NSWindow                        *window;
    NSString                        *message;
    NSString                        *action;
    NSDate                          *startTime;
    double                          progress;
    NSTimeInterval                  remainingTime;
    unsigned long long              sizeWritten;
    unsigned long long              totalSize;
    unsigned long long              totalCount;
    BOOL                            isIndeterminate;
    NSOperationQueue                *bscQueue;
    IBOutlet NSProgressIndicator    *progressIndicator;
    IBOutlet NSButton               *stopButton;
}

@property (assign)  IBOutlet    NSWindow *window;
@property (copy)    NSString            *message;
@property (copy)    NSString            *action;
@property (retain)  NSDate              *startTime;
@property (assign)  double              progress;
@property (assign)  NSTimeInterval      remainingTime;
@property (assign)  unsigned long long  sizeWritten;
@property (assign)  unsigned long long  totalSize;
@property (assign)  unsigned long long  totalCount;
@property (assign)  BOOL                isIndeterminate;
@property (retain)  NSOperationQueue    *bscQueue;

- (IBAction) cancel:(id)sender;
- (BOOL) process:(NSArray *)listOfPaths;

@end
