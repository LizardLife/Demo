//
//  NSString+StringSize.m
//  Label
//
//  Created by qingyun on 14-12-11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "NSString+StringSize.h"

@implementation NSString (StringSize)

-(CGSize)calculateSize:(CGSize)size font:(UIFont *)font{
    CGSize expectedSize = CGSizeZero;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 7) {
        expectedSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    }
    else{
        NSMutableParagraphStyle *paragraphstyle = [[NSMutableParagraphStyle alloc] init];
        paragraphstyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName :font, NSParagraphStyleAttributeName:paragraphstyle};
        expectedSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    return expectedSize;
}

@end
