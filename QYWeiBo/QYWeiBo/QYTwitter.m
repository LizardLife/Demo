//
//  QYTwitter.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTwitter.h"
#import "Common.h"
#import "QYUser.h"

@implementation QYTwitterData

-(instancetype)initWithDictionary:(NSDictionary *)info{
    self = [super init];
    if (self) {
        //设置属性
        self.user = [[QYUser alloc] initWithDictionary:info[kUser]];
        //微博发布时间
        NSString *dateString = info[@"created_at"];
        
        NSString *dateFormater = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFormater];
        self.created_at = [formatter dateFromString:dateString];
        
        self.twitterId = info[@"id"];
        if ([self.twitterId isKindOfClass:[NSNumber class]]) {
            self.twitterId = [info[@"id"] stringValue];
        }
        self.text = info[@"text"];
        NSString *sourceString = info[@"source"];
        self.source = [self sourceWithString:sourceString];
        self.favorited = [info[@"favorited"] boolValue];
        self.reposts_count = [info[@"reposts_count"] integerValue];
        self.comments_count = [info[@"comments_count"] integerValue];
        self.attitudes_count = [info[@"attitudes_count"] integerValue];
        NSArray * imageArray = info[@"pic_urls"];
        NSMutableArray *muImgAr = [NSMutableArray array];
        for (NSDictionary *dic in imageArray) {
            [muImgAr addObjectsFromArray:dic.allValues];
        }
        self.pic_urls = muImgAr;
        
    }
    return self;
}

-(NSString *)timeAgo{
    return [self dateStringWithDate:self.created_at];
}

//针对微博的时间显示
-(NSString *)dateStringWithDate:(NSDate *)date{
    NSTimeInterval interval = -[date timeIntervalSinceNow];
    //
    if (interval < 60) {//秒
        return @"刚刚";
    }else if (interval < 60 * 60){
        //分钟
        return [NSString stringWithFormat:@"%d分钟前", (NSInteger)interval/60];
    }else if (interval < 60 * 60 * 24){
        //小时
        return [NSString stringWithFormat:@"%d小时前", (NSInteger)interval/(60 * 60)];
    }else{
        NSString *formatterString = @"MMM dd HH:mm";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = formatterString;
        return [formatter stringFromDate:date];
    }
}

//解析微博的来源
-(NSString *)sourceWithString:(NSString *)string{
    NSString *source;
    NSString *regExStr = @">.*<";
    if ([string isEqualToString:@""] || string == nil || [string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regExStr options:0 error:nil];
    NSTextCheckingResult *result = [expression firstMatchInString:string options:0 range:NSMakeRange(0, string.length -1)];
    if (result) {
        NSRange range = [result rangeAtIndex:0];
        source = [string substringWithRange:NSMakeRange(range.location + 1, range.length -2)];
    }
    return source;
}

@end

@implementation QYTwitter

-(instancetype)initWithDictionary:(NSDictionary *)info{
    //info > twitterdata
    //info[re] > retitterdata
    self = [super init];
    if (self) {
        self.twitterData = [[QYTwitterData alloc] initWithDictionary:info];
        NSDictionary *reInfo = info[kRetweeted_status];
        if (reInfo) {
            self.reTwitterData = [[QYTwitterData alloc] initWithDictionary:info[kRetweeted_status]];
        }
    }
    return self;
}

@end
