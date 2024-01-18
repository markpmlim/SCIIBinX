//
//  AppDelegate.m
//  SCIIBinX
//
//  Created by mark lim on 10/7/17.
//  Copyright 2017 Incremental Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

@synthesize extensionsView;
@synthesize mainWinController;
@synthesize extensionTag;

FILE *logFilePtr = NULL;

- (id)init
{
    //NSLog(@"min version:%d", __MAC_OS_X_VERSION_MIN_REQUIRED);
    if (NSAppKitVersionNumber < 949)
    {
        // Pop up a warning dialog, 
        NSRunAlertPanel(@"Sorry, this program requires Mac OS X 10.5 or later", @"You are running %@", 
                        @"OK", nil, nil, [[NSProcessInfo processInfo] operatingSystemVersionString]);
        
        // then quit the program
        [NSApp terminate:self]; 
        
    }
    self = [super init];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    NSURL *logURL = [self urlOfLogFile];
    if (logURL != nil)
    {
        logFilePtr = freopen([logURL.path fileSystemRepresentation], "a+", stderr);
        if (logFilePtr == NULL)
        {
            NSLog(@"Could not open the console log file. All messages will be sent to system log.");
        }
    }

    self.extensionTag = 1;
}

- (void)applicationWillTerminate:(NSNotification *)note 
{
    //printf("applicationWillTerminate\n");
    if (logFilePtr != NULL) {
        fclose(logFilePtr);
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

// This method handle the situation when the user double-clicks on a
// single or multiple BSC/BSQ files.
- (void)application:(NSApplication *)sender
          openFiles:(NSArray *)filenames
{
    //printf("processing files\n");
    BOOL success = [self.mainWinController process:filenames];
    // The statement below is recommended.
    [NSApp replyToOpenOrPrint:success ? NSApplicationDelegateReplySuccess : NSApplicationDelegateReplyFailure];
}

// Returns the url to SCIIBinX's console log file.
// It will create the folder /Users/marklim/Library/"Application Support"/SCIIBinX
// if it does not exist.
- (NSURL *)urlOfLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *basePath = [paths objectAtIndex:0];
    NSString *logFolder = [basePath stringByAppendingString:@"/SCIIBinX"];
    NSFileManager *fmgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // Note: The response returned by the OS will depend on whether the path
    // has a trailing slash or not.
    // The call below will return NO irrespective of whether or not there is
    // a regular file at the location.
    BOOL exists = [fmgr fileExistsAtPath:logFolder
                             isDirectory:&isDir];
    if (exists == YES && isDir == NO)
    {
        NSString *message = [NSString localizedStringWithFormat:@"A file (not folder) with the name \"SCIIBinX\" exists at the location\n%@.", basePath];
        NSAlert *alert = [NSAlert alertWithMessageText:message
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"All messages will be send to the system log."];
        [alert runModal];
        logFilePtr = NULL;
        return nil;
    }
    else if (!exists)
    {
        //NSLog(@"Creating the Application Support folder: %@", logFolder);
        NSError *outErr = nil;
        if ([fmgr createDirectoryAtPath:logFolder
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&outErr] == NO) 
        {
            NSString *message = [NSString localizedStringWithFormat:@"Creating the folder %@\n failed", logFolder];
            NSAlert *alert = [NSAlert alertWithMessageText:message
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"All messages will be send to the system log."];
            [alert runModal];
            logFilePtr = NULL;
            return nil;
        }
    }
    
    // If we get here, the folder "NuShrinkItX" already exists or is newly-created.
    NSString *logPath = [logFolder stringByAppendingString:@"/messages.log"];
    NSURL *urlLog = [NSURL fileURLWithPath:logPath];
    return urlLog;
}

// Open the "ReadMe.txt" in the default text editor
- (IBAction)showHelp:(id)sender
{
    NSString *fullPathname;
    fullPathname = [[NSBundle mainBundle] pathForResource:@"Readme"
                                                   ofType:@"rtf"];
    [[NSWorkspace sharedWorkspace] openFile:fullPathname];
}

- (IBAction)changeFileExtension:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    oPanel.allowsMultipleSelection = YES;
    oPanel.canChooseDirectories = NO;
    oPanel.accessoryView = extensionsView;
    oPanel.prompt = @"Change";
    NSInteger buttonID = [oPanel runModal];
    if (buttonID == NSFileHandlingPanelOKButton)
    {
        NSString *newExtension = nil;
        if (self.extensionTag == 1) 
        {
            newExtension = @"BSC";
        }
        else
        {
            newExtension = @"BSQ";
        }

        NSArray *urls = [oPanel URLs];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        for (NSURL *url in urls)
        {
            NSString *path = url.path;
            NSString *newPath = [path stringByDeletingPathExtension];
            newPath = [newPath stringByAppendingPathExtension:newExtension];
            if ([newPath localizedCaseInsensitiveCompare:path] != NSOrderedSame)
            {
                [fm moveItemAtPath:path
                            toPath:newPath
                             error:&error];
                if (error != nil)
                {
                    NSLog(@"%@ could not be renamed to %@. Error: %@", path, newPath, error);
                }
            }
        }
    }
}

- (IBAction)showLogs:(id)sender;
{
    if (logFilePtr != NULL)
    {
        fflush(logFilePtr);
        NSURL *consoleURL = [self urlOfLogFile];
        NSString *logFilePath = consoleURL.path;
        // We assume nobody gets funny and remove the log file while
        // the program is executing.
        [[NSWorkspace sharedWorkspace] openFile:logFilePath
                                withApplication:@"Console.app"];
    }
}

- (IBAction)removeLogs:(id)sender 
{
    if (logFilePtr != NULL)
    {
        fflush(logFilePtr);
        rewind(logFilePtr);
        ftruncate(fileno(logFilePtr), 0);
    }
}
@end
