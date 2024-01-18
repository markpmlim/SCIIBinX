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

// A delegate is not necessary.
@interface BSCOperation : NSOperation
{
    NSArray *pathNames;
}

- (id)initWithPaths:(NSArray *)paths;

@end
