//
//  QYTwitter.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//



#import <Foundation/Foundation.h>

@class QYUser;
@interface QYTwitterData : NSObject

@property (nonatomic, strong)NSDate * created_at;
@property (nonatomic, strong)NSString *twitterId;
@property (nonatomic, strong)NSString *text;
@property (nonatomic, strong)NSString *source;
@property (nonatomic) BOOL favorited;
@property (nonatomic, strong)QYUser *user;
@property (nonatomic) NSInteger reposts_count;
@property (nonatomic)NSInteger comments_count;
@property (nonatomic)NSInteger attitudes_count;
@property (nonatomic, strong)NSArray *pic_urls;
@property (nonatomic)NSString *timeAgo;

-(instancetype)initWithDictionary:(NSDictionary *)info;


//解析微博的来源
-(NSString *)sourceWithString:(NSString *)string;
@end

@interface QYTwitter : NSObject

@property (nonatomic, strong)QYTwitterData *twitterData;
@property (nonatomic, strong)QYTwitterData *reTwitterData;

-(instancetype)initWithDictionary:(NSDictionary *)info;

@end
