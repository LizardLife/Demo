//
//  QYWeiBoCell.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-12.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

//绑定模型或者字典
//根据微博信息返回cell高度

#import <UIKit/UIKit.h>

@class QYTwitter;

@interface QYWeiBoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *contentImage;
@property (weak, nonatomic) IBOutlet UILabel *transmitLabel;
@property (weak, nonatomic) IBOutlet UIView *transmitImage;

//计算cell高度
-(CGFloat)cellHeight4TwitterData:(QYTwitter *)info;

-(void)setTwitterData:(QYTwitter *)info;

@end
