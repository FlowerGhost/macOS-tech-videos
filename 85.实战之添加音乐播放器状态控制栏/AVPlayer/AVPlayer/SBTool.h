//
//  SBTool.h
//  AVPlayer
//
//  Created by mac on 2018/8/8.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
@interface SBTool : NSObject
//将CMTime转换成时间秒
+(NSTimeInterval)convertCMTime:(CMTime)time;
//将秒转换成时间
+(NSString *)convertTime:(CGFloat)second;

@end
