//
//  QYDataBaseEngine.h
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYDataBaseEngine : NSObject

+(void)saveTwitterToDatabase:(NSArray *)twitterArray;

//从DB查询数据, 查询最新的20条
+(NSArray *)selectTwitterFromDB;

@end
