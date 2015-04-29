//
//  QYComment.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYComment.h"
#import "Common.h"
#import "QYUser.h"
#import "QYTwitter.h"

@implementation QYCommentData

-(instancetype)initWithDictionary:(NSDictionary *)info{
    self = [super init];
    if (self) {
        self.created_at = info[@"created_at"];
        self.comment_id = info[@"id"];
        self.text = info[@"text"];
        self.source = info[@"source"];
        self.user = [[QYUser alloc] initWithDictionary:info[@"user"]];
        self.status = [[QYTwitter alloc] initWithDictionary:info[@"status"]];
    }
    return self;
}

@end

@implementation QYComment

-(instancetype)initWirhDictionary:(NSDictionary *)info{
    self = [super init];
    if (self) {
        self.commentData = [[QYCommentData alloc] initWithDictionary:info];
        NSDictionary *replyInfo = [info objectForKey:@"reply_comment"];
        if (replyInfo) {
            self.reply_commentData = [[QYCommentData alloc] initWithDictionary:replyInfo];
        }
        
    }
    return self;
}

@end
