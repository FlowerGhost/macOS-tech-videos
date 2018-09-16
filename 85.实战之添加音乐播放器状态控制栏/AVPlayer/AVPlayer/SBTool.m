//
//  SBTool.m
//  AVPlayer
//
//  Created by mac on 2018/8/8.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import "SBTool.h"

@implementation SBTool
+(NSTimeInterval)convertCMTime:(CMTime)time {
    return time.value / time.timescale;
}
+(NSString *)convertTime:(CGFloat)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *resultTime = [formatter stringFromDate:d];
    return resultTime;
}
@end
