//
//  VideoURLModel.h
//  AVPlayer
//
//  Created by mac on 2018/8/10.
//  Copyright © 2018年 石彪. All rights reserved.
//

//#import "RLMObject.h"
#import <Realm/Realm.h>
@interface VideoURLModel : RLMObject
@property NSString *urlPath;
@end
RLM_ARRAY_TYPE(VideoURLModel)
