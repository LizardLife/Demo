//
//  QYAccountInfo.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYAccountInfo.h"
#import "Common.h"

static QYAccountInfo *accountInfo;

@interface QYAccountInfo ()



@end

@implementation QYAccountInfo

+(id)shareAccountInfo{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        accountInfo = [[QYAccountInfo alloc] init];
    });
    return accountInfo;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        self.token = [userD objectForKey:access_token];
        self.userId = [userD objectForKey:uid];
        NSDate *date = [userD objectForKey:expires_in];
        if (self.token && ![date compare:[NSDate date]]  == NSOrderedDescending) {
            [self deleteAccoutInfo];
        }
    }
    return self;
}

-(void)saveLoginInfo:(NSDictionary *)info{
    self.token = info[access_token];
    self.userId = info[uid];
    
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:self.token forKey:access_token];
    [userD setObject:self.userId forKey:uid];
    
    NSTimeInterval time = [info[expires_in] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:time];
    [userD setObject:date forKey:expires_in];
    [userD synchronize];
}

-(void)deleteAccoutInfo{
    self.token = nil;
    self.userId = nil;
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:nil forKey:access_token];
    [userD setObject:nil forKey:uid];
    [userD setObject:nil forKey:expires_in];
    [userD synchronize];
}

-(BOOL)isLogin{
    return self.token != nil;
}



@end
