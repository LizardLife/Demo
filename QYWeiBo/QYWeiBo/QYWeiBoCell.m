//
//  QYWeiBoCell.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYWeiBoCell.h"
#import "UIImageView+WebCache.h"
#import "QYTextHeight.h"
#import "NSString+StringSize.h"
#import "QYTwitter.h"
#import "QYUser.h"

NSInteger imageX = 90;
NSInteger imageY = 90;
NSInteger imageEdge = 5;

@implementation QYWeiBoCell

//方法一
//-(CGFloat)cellHeight4TwitterData:(NSDictionary *)info{
//    //内容的y开始计算
//    CGFloat cellHeight = 66;
//    NSString *contentStr = info[@"text"];
//    cellHeight += [contentStr calculateSize:CGSizeMake(304, 1000) font:[UIFont systemFontOfSize:17]].height;
//    cellHeight += 8;
//    
//    //图片的高度
//    NSArray *imageArray = [info objectForKey:@"pic_urls"];
//    if (imageArray.count != 0) {
//        NSInteger line = ceil(imageArray.count/3.f);
//        NSInteger imageHeight = line *imageY + (line - 1)*imageEdge;
//        cellHeight += imageHeight;
//    }
//    cellHeight += 8;
//    
//    //转发内容
//    
//    NSDictionary *retwitter = [info objectForKey:@"retweeted_status"];
//    if (retwitter) {
//        NSString *contentStr = retwitter[@"text"];
//        cellHeight += [contentStr calculateSize:CGSizeMake(304, 1000) font:[UIFont systemFontOfSize:17]].height;
//        cellHeight += 8;
//        
//        //图片的高度
//        NSArray *imageArray = [retwitter objectForKey:@"pic_urls"];
//        if (imageArray.count != 0) {
//            NSInteger line = ceil(imageArray.count/3.f);
//            NSInteger imageHeight = line *imageY + (line - 1)*imageEdge;
//            cellHeight += imageHeight;
//        }
//    }
//    return cellHeight + 1;
//}

//方法二：

//-(CGFloat)cellHeight4TwitterData:(NSDictionary *)info{
//    //从正文开始计算，之上的高度是确定的
//    CGFloat cellHeight = 66.f;
//    NSString *content = info[@"text"];
//    cellHeight += [QYTextHeight textHeightWith:content FontSize:17 inWidth:0];
//    //加上间隔的距离；
//    cellHeight += 8;
//    NSArray *imageArray = [info objectForKey:@"pic_urls"];
//    if (imageArray.count != 0) {
//        NSInteger line = ceil(imageArray.count/ 3.f);
//        NSInteger imageViewHeight = line * imageY + (line - 1)* imageEdge;
//        cellHeight += imageViewHeight;
//    }
//    cellHeight += 8;
//    NSDictionary * retweeted = info[@"retweeted_status"];
//    if (retweeted) {
//        NSString *content = retweeted[@"text"];
//        cellHeight += [QYTextHeight textHeightWith:content FontSize:17 inWidth:0];
//        //加上间隔的距离；
//        cellHeight += 8;
//        NSArray *imageArray = [retweeted objectForKey:@"pic_urls"];
//        if (imageArray.count != 0) {
//            NSInteger line = ceil(imageArray.count/ 3.f);
//            NSInteger imageViewHeight = line * imageY + (line - 1)* imageEdge;
//            cellHeight += imageViewHeight;
//        }
//    }
//    //加上分割线的高度
//    return cellHeight + 1;
//}


//方法三
-(CGFloat)cellHeight4TwitterData:(QYTwitter *)twitter{
    //计算整体的高度
    CGFloat cellHeight = 0.f;
    self.contentLabel.text = twitter.twitterData.text;
    
    //计算图片的高度
    NSArray *imageArray = twitter.twitterData.pic_urls;
    if (imageArray.count != 0) {
        NSInteger line = ceil(imageArray.count/ 3.f);
        NSInteger imageViewHeight = line * imageY + (line - 1)* imageEdge;
        cellHeight += imageViewHeight;
    }
    
    QYTwitterData *reTwitter = twitter.reTwitterData;
    self.transmitLabel.text = reTwitter.text;
    
    //计算整体高度，除了两处显示图片的高度
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    cellHeight += size.height;
    
    imageArray = reTwitter.pic_urls;
    if (imageArray.count != 0) {
        NSInteger line = ceil(imageArray.count/3.f);
        NSInteger imageViewHeight = line * imageY + (line - 1)* imageEdge;
        cellHeight += imageViewHeight;
    }
    
    return cellHeight + 1;
}

-(void)setTwitterData:(QYTwitter *)twitter{
    QYUser *user = twitter.twitterData.user;
    NSString *iconUrlStr = user.profile_image_url;
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:iconUrlStr] placeholderImage:nil];
    [self.nickNameLabel setTitle:user.name forState:UIControlStateNormal];
    
    NSString *dateString = twitter.twitterData.timeAgo;
    NSString *sourceString = twitter.twitterData.source;
    
//    NSString *dateFormater = @"EEE MMM dd HH:mm:ss zzz yyyy";
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:dateFormater];
//    NSDate *date = [formatter dateFromString:dateString];
    
//    NSString *agoTimeString = [self dateStringWithDate:date];
//    NSString *souece = [self sourceWithString:sourceString];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@    %@", dateString, sourceString];
    self.contentLabel.text = twitter.twitterData.text;

    NSArray *imageArray = twitter.twitterData.pic_urls;
    [self layoutImage:imageArray forView:self.contentImage];
    
    //转发内容
    QYTwitterData *retweeted = twitter.reTwitterData;
    self.transmitLabel.text = retweeted.text;
    imageArray = retweeted.pic_urls;
    [self layoutImage:imageArray forView:self.transmitImage];
    
}

-(void)layoutImage:(NSArray *)images forView:(UIView *)view{
    
    //移除之前添加的图片
    NSArray *subViews = view.subviews;
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
    
    NSInteger line = ceil(images.count/3.f);
    NSInteger imageHeight = line * imageY + (line - 1) * imageEdge;
    imageHeight = imageHeight < 0 ? 0 : imageHeight;
    for (NSLayoutConstraint *constraint in view.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeHeight){
            constraint.constant = imageHeight;
        }
    }
    for (int i = 0; i< images.count ; i++) {
        NSString *imageUrlStr = [images objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i%3 * (imageX + imageEdge), i/3 * (imageX + imageEdge), imageX, imageY)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr]];
        [view addSubview:imageView];
    }
}

////针对微博的时间显示
//-(NSString *)dateStringWithDate:(NSDate *)date{
//    NSTimeInterval interval = -[date timeIntervalSinceNow];
//    //
//    if (interval < 60) {//秒
//        return @"刚刚";
//    }else if (interval < 60 * 60){
//        //分钟
//        return [NSString stringWithFormat:@"%ld分钟前", (NSInteger)interval/60];
//    }else if (interval < 60 * 60 * 24){
//        //小时
//        return [NSString stringWithFormat:@"%ld小时前", (NSInteger)interval/(60 * 60)];
//    }else{
//        NSString *formatterString = @"MMM dd HH:mm";
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = formatterString;
//        return [formatter stringFromDate:date];
//    }
//}
//
////解析微博的来源
//-(NSString *)sourceWithString:(NSString *)string{
//    NSString *source;
//    NSString *regExStr = @">.*<";
//    if ([string isEqualToString:@""] || string == nil || [string isKindOfClass:[NSNull class]]) {
//        return nil;
//    }
//    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regExStr options:0 error:nil];
//    NSTextCheckingResult *result = [expression firstMatchInString:string options:0 range:NSMakeRange(0, string.length -1)];
//    if (result) {
//        NSRange range = [result rangeAtIndex:0];
//        source = [string substringWithRange:NSMakeRange(range.location + 1, range.length -2)];
//    }
//    return source;
//}

@end
