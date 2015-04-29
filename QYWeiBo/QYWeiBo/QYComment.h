//
//  QYComment.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QYUser, QYTwitter;
@interface QYCommentData : NSObject

@property (nonatomic, strong)NSString *created_at;
@property (nonatomic, strong)NSString *comment_id;
@property (nonatomic, strong)NSString *text;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong)QYUser *user;
@property (nonatomic, strong)QYTwitter *status;

-(instancetype)initWithDictionary:(NSDictionary *)info;

@end

@interface QYComment : NSObject

@property (nonatomic, strong)QYCommentData *commentData;
@property (nonatomic, strong)QYCommentData *reply_commentData;

-(instancetype)initWirhDictionary:(NSDictionary *)info;
@end
