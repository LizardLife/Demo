//
//  QYTwitterFooterView.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-13.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYTwitterFooterView.h"

@implementation QYTwitterFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor whiteColor];
}

@end
