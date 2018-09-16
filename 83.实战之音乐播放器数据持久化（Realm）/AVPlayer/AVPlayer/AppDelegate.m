//
//  AppDelegate.m
//  AVPlayer
//
//  Created by mac on 2018/8/7.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSApp.applicationIconImage = [NSImage imageNamed:@"AppIcon"];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.windowController.window makeKeyAndOrderFront:nil];
    return YES;
}
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    
    ViewController *vc = (ViewController *)self.windowController.contentViewController;
    NSURL *fileURL = [NSURL fileURLWithPath:filename];
    [vc.dataArr addObject:fileURL];
    vc.selectedFileURL = fileURL;
    [vc saveURLToDataBaseWithURL:fileURL];
    [self.windowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}
@end
