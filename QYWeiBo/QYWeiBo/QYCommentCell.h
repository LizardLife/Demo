//
//  QYCommentCell.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <UIKit/UIKit.h>


@class QYComment;
@interface QYCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *name;
@property (weak, nonatomic) IBOutlet UILabel *creatAt;
@property (weak, nonatomic) IBOutlet UILabel *commentText;

-(CGFloat)cellHeight4Comment:(QYComment*)comment;

-(void)setComment:(QYComment *)comment;

@end
