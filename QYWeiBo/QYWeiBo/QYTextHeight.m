//
//  QYTextHeight.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTextHeight.h"

static UILabel *label;

@implementation QYTextHeight

+ (void)initialize
{
    if (self == [QYTextHeight class]) {
        //初始化一个专门用来计算文字内容高度的label
        NSInteger defaultWidth = [[UIScreen mainScreen] bounds].size.width - 16;
        label = [[UILabel alloc] init];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:defaultWidth];
        [label addConstraint:constraint];
    }
}

+(CGFloat )textHeightWith:(NSString *)string FontSize:(NSInteger)fontSize inWidth:(float)width{
    label.font = [UIFont systemFontOfSize:fontSize];
    NSArray *constraints;
    if (width != 0 && label.bounds.size.width != width) {
        constraints = label.constraints;
        [label removeConstraints:label.constraints];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
        [label addConstraint:constraint];
    }
    label.text = string;
    
    CGSize size = [label systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (constraints) {
         [label removeConstraints:label.constraints];
        [label addConstraints:constraints];
    }
   
    return size.height;
}


@end
