//
//  QYUser.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYUser.h"

@implementation QYUser

-(instancetype)initWithDictionary:(NSDictionary *)info{
    self = [super init];
    if (self) {
        //设置属性
        self.userId = info[@"id"];
        self.name = info[@"name"];
        self.profile_image_url = info[@"profile_image_url"];
    }
    return self;
}

@end
