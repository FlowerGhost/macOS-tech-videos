//
//  WindowController.m
//  AVPlayer
//
//  Created by mac on 2018/8/8.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import "WindowController.h"
#import "AppDelegate.h"
@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    AppDelegate *delegate = [NSApp delegate];
    delegate.windowController = self;
    
    self.window.movableByWindowBackground = YES;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
