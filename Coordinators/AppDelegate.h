//
//  AppDelegate.h
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Forward declaration.
@class MainWindowController;

@interface AppDelegate : NSObject //<NSApplicationDelegate>
{
    NSView                  *extensionsView;
    MainWindowController    *mainWinController;
    unsigned int            extensionTag;
}

@property (assign) IBOutlet NSView *extensionsView;
@property (assign) IBOutlet MainWindowController *mainWinController;
@property (assign, readwrite) unsigned int  extensionTag;


- (IBAction) showHelp:(id)sender;
- (IBAction) changeFileExtension:(id)sender;
- (IBAction) showLogs:(id)sender;
- (IBAction) removeLogs:(id)sender;

// Internal methods
-(NSURL *) urlOfLogFile;

@end
