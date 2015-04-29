//
//  QYCommentCell.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYCommentCell.h"
#import "QYComment.h"
#import "QYUser.h"
#import "UIImageView+WebCache.h"

@implementation QYCommentCell

-(CGFloat)cellHeight4Comment:(QYComment *)comment{
    self.commentText.text = comment.commentData.text;
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)setComment:(QYComment *)comment{
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:comment.commentData.user.profile_image_url]];
    [self.name setTitle:comment.commentData.user.name forState:UIControlStateNormal];
    [self.creatAt setText:comment.commentData.created_at];
    [self.commentText setText:comment.commentData.text];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
