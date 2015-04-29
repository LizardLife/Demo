//
//  QYAccountInfo.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYAccountInfo : NSObject

@property (nonatomic, strong)NSString *token;
@property (nonatomic, strong)NSString *userId;

//保存用户的登陆信息
//删除用户的登陆信息
//返回用户的登录状态

+(id)shareAccountInfo;

-(void)saveLoginInfo:(NSDictionary*)info;

-(void)deleteAccoutInfo;
-(BOOL)isLogin;

@end
