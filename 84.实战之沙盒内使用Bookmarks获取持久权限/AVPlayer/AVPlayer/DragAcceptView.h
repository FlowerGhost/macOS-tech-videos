//
//  DragAcceptView.h
//  AVPlayer
//
//  Created by mac on 2018/8/8.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DragAcceptView;
@protocol DragAcceptViewDelegate<NSObject>
@optional
-(void)dragAcceptView:(DragAcceptView *)dragView draggedFilesWithURLs:(NSArray *)urlArr;
@end
@interface DragAcceptView : NSView
@property (nonatomic,weak) id<DragAcceptViewDelegate>  delegate;

@end
