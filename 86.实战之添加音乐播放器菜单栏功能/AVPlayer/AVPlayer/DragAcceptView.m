//
//  DragAcceptView.m
//  AVPlayer
//
//  Created by mac on 2018/8/8.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import "DragAcceptView.h"

@implementation DragAcceptView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSString *UTTypeString = (__bridge NSString *)kUTTypeURL;
        //注册所有文件格式
        [self registerForDraggedTypes:[NSArray arrayWithObject:UTTypeString]];
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *audiovisualcontent = (__bridge NSString *)kUTTypeAudiovisualContent;
    NSDictionary *filteringOptions = [NSDictionary dictionaryWithObject:audiovisualcontent forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    if ([pasteboard canReadObjectForClasses:@[[NSURL class]] options:filteringOptions]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSArray *pboardArray = [[sender draggingPasteboard]propertyListForType:NSFilenamesPboardType];
    NSMutableArray *urlsArr = [NSMutableArray array];
    for (NSString *path in pboardArray) {
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [urlsArr addObject:fileURL];
    }
    
    if ([self.delegate respondsToSelector:@selector(dragAcceptView:draggedFilesWithURLs:)]) {
        [self.delegate dragAcceptView:self draggedFilesWithURLs:urlsArr];
    }
    return YES;
}
@end
