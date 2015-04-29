//
//  QYUser.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *profile_image_url;

-(instancetype)initWithDictionary:(NSDictionary *)info;

@end
