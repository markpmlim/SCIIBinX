//
//  BSCOperation.h
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
extern NSString *const cancelledOperationsNote;
extern NSString *const finishedOperationsNote;

@interface BSCOperation : NSOperation {
    NSArray *pathNames;
    MainWindowController *delegate;
}

-(id) initWithPaths:(NSArray *)paths
        andDelegate:(MainWindowController *)del;

@end
