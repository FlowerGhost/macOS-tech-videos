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
@property (nonatomic,strong) NSStatusItem *statusItem;
@property (nonatomic,strong) ViewController *vc;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    self.vc = (ViewController *)self.windowController.contentViewController;
    self.statusItem.view = self.vc.statusView;
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.windowController.window makeKeyAndOrderFront:nil];
    return YES;
}
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    
    NSURL *fileURL = [NSURL fileURLWithPath:filename];
    [self.vc.dataArr addObject:fileURL];
    self.vc.selectedFileURL = fileURL;
    [self.vc saveURLToDataBaseWithURL:fileURL];
    [self.windowController.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}
- (IBAction)openFile:(NSMenuItem *)sender {
    [self.vc openFile];
}

@end
