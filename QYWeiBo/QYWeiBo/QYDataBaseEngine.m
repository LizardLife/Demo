//
//  QYDataBaseEngine.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-15.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

//1.讲文件复制到Coduments;
//2.插入方法（twitter， twitterData， user）
//2.1创建插入语句
//2.2执行插入操作，

#import "QYDataBaseEngine.h"
#import "FMDB.h"
#import "Common.h"
#import "QYTwitter.h"
#import "QYUser.h"

#define kSourceDataBaseFile @"TwitterData"

#define kTableNameTweet @"tweet"
#define kTableNameTweetdata @"tweetdata"
#define kTableNameUser @"user"

static NSArray *twitterTableColumn;
static NSArray *twitterDataColumn;
static NSArray *userTabelColumn;

@implementation QYDataBaseEngine

+ (void)initialize
{
    if (self == [QYDataBaseEngine class]) {
        [QYDataBaseEngine copyFile2Documents];
        twitterTableColumn = [QYDataBaseEngine tableColumn4Table:kTableNameTweet];
        twitterDataColumn = [QYDataBaseEngine tableColumn4Table:kTableNameTweetdata];
        userTabelColumn = [QYDataBaseEngine tableColumn4Table:kTableNameUser];
    }
}

+(NSArray *)tableColumn4Table:(NSString *)table{
    FMDatabase *db = [FMDatabase databaseWithPath:[QYDataBaseEngine databaseFilePath]];
    //查询table的所有字段名
    NSMutableArray *column = [NSMutableArray array];
    [db open];
    FMResultSet *result = [db getTableSchema:table];
    while ([result next]) {
        NSString *columnName = [[result stringForColumn:@"name"] lowercaseString];
        [column addObject:columnName];
    }
    [result close];
    [db close];
    return column;
}

+(void)copyFile2Documents{
    
    NSString *filePath = [QYDataBaseEngine databaseFilePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:filePath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:kSourceDataBaseFile ofType:@"sqlite"];
        [manager copyItemAtPath:sourcePath toPath:filePath error:nil];
    }
    
}
/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)databaseFilePath{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"TwitterData.sqlite"];
    return filePath;
}

+(void)saveTwitterToDatabase:(NSArray *)twitterArray{
    NSString *filePath = [QYDataBaseEngine databaseFilePath];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [queue inDatabase:^(FMDatabase *db) {

        for (NSDictionary *twitter in twitterArray) {
            
            //插入twitter
            NSMutableDictionary *twitterInfo = [NSMutableDictionary dictionary];
            NSString *twitterId = twitter[@"id"];
            [twitterInfo setObject:twitterId forKey:@"id"];
            NSDictionary *reTwitter = twitter[kRetweeted_status];
            if (reTwitter) {
                NSString *reTwitterId = reTwitter[@"id"];
                [twitterInfo setObject:reTwitterId forKey:@"retweet_id"];
            }
            [QYDataBaseEngine insertTwitter:twitterInfo DB:db];
            
            //插入TwitterData
            
            [QYDataBaseEngine insetTwitterData:twitter DB:db];
            if (reTwitter) {
                [QYDataBaseEngine insetTwitterData:reTwitter DB:db];
            }
            
            //插入user
            [QYDataBaseEngine insertUser:twitter[kUser] DB:db];
            if (reTwitter) {
                [QYDataBaseEngine insertUser:reTwitter[kUser] DB:db];
            }
            
            
        }
    }];
}

+(void)insertTwitter:(NSDictionary *)twitter DB:(FMDatabase *)db{
    NSString *sqlString = [QYDataBaseEngine insertsqlString4Table:kTableNameTweet Keys:twitter.allKeys];
    [db executeUpdate:sqlString withParameterDictionary:twitter];
}

+(void)insetTwitterData:(NSDictionary *)twitterData DB:(FMDatabase*)db{
    //筛选有用的key
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:twitterData.allKeys];
    NSMutableDictionary *muTwitterData = [NSMutableDictionary dictionary];
    for (NSString *column in twitterDataColumn) {
        if ([allKeys containsObject:column]) {
            [muTwitterData setObject:twitterData[column] forKey:column];
        }
    }
    
    NSString *sqlString = [QYDataBaseEngine insertsqlString4Table:kTableNameTweetdata Keys:muTwitterData.allKeys];
    //将user 替换成 userid
    NSDictionary *userInfo = [muTwitterData objectForKey:kUser];
    [muTwitterData setObject:userInfo[@"id"] forKey:kUser];
    //将image 组合成字符串
    NSArray *images = [muTwitterData objectForKey:kTwitterImage];
    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:images.count];
    for (NSDictionary *dic in images) {
        [imageUrls addObjectsFromArray:dic.allValues];
    }
    [muTwitterData setObject:[imageUrls componentsJoinedByString:@","] forKey:kTwitterImage];
    
    [db executeUpdate:sqlString withParameterDictionary:muTwitterData];
    
    
    
}

+(void)insertUser:(NSDictionary *)user DB:(FMDatabase *)db{
    //筛选有用的数据
    NSMutableDictionary *muUser = [NSMutableDictionary dictionary];
    for (NSString *column in userTabelColumn) {
        if ([user.allKeys containsObject:column]) {
            [muUser setObject:user[column] forKey:column];
        }
    }
    
    // 创建sql语句
    NSString *sqlString = [QYDataBaseEngine insertsqlString4Table:kTableNameUser Keys:muUser.allKeys];
    [db executeUpdate:sqlString withParameterDictionary:muUser];
}

//创建Sql语句的方法

+(NSString *)insertsqlString4Table:(NSString *)tableName Keys:(NSArray *)keys{
    
    NSString *allkeys = [keys componentsJoinedByString:@", "];
    NSString *allValues= [keys componentsJoinedByString:@", :"];
    allValues = [@":" stringByAppendingString:allValues];
    
    return [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", tableName, allkeys, allValues];

}

+(NSArray *)selectTwitterFromDB{
    //open db
    //sqlstring
    //执行
    //遍历
    
    FMDatabase *db = [FMDatabase databaseWithPath:[QYDataBaseEngine databaseFilePath]];
    [db open];
    
    NSString *sqlString = @"select * from tweet order by id desc limit 20";
    
    FMResultSet *result = [db executeQuery:sqlString];
    
    NSMutableArray *twitters = [NSMutableArray arrayWithCapacity:20];
    
    while ([result next]) {
        id twitterId = [result objectForColumnName:@"id"];
        id reTwitterId = [result objectForColumnName:@"retweet_id"];
        QYTwitter *twitter = [[QYTwitter alloc] init];
        twitter.twitterData = [QYDataBaseEngine selectTwitterData4ID:twitterId DB:db];
        if (reTwitterId) {
            twitter.reTwitterData = [QYDataBaseEngine selectTwitterData4ID:reTwitterId DB:db];
        }
        [twitters addObject:twitter];
    }
    [result close];
    [db close];
    
    return twitters;
}

//查询TwitterData

+(QYTwitterData *)selectTwitterData4ID:(id)twitterId DB:(FMDatabase *)db
{
    NSString *sqlString = @"select * from tweetdata where id = ?";
    FMResultSet *result = [db executeQuery:sqlString, twitterId];
    QYTwitterData *twitterData;
    if ([result next]) {
        twitterData = [[QYTwitterData alloc] init];
        //....绑定属性
        NSString *dateString = [result stringForColumn:@"created_at"];
        
        NSString *dateFormater = @"EEE MMM dd HH:mm:ss zzz yyyy";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:dateFormater];
        twitterData.created_at = [formatter dateFromString:dateString];
        
        twitterData.twitterId = [result stringForColumn:@"id"];
        twitterData.text = [result stringForColumn:@"text"];
        NSString *sourceString = [result stringForColumn:@"source"];
        twitterData.source = [twitterData sourceWithString:sourceString];
        twitterData.favorited = [result boolForColumn:@"favorited"];
        twitterData.reposts_count = [result intForColumn:@"reposts_count"];
        twitterData.comments_count = [result intForColumn:@"comments_count"];
        twitterData.attitudes_count= [result intForColumn:@"attitudes_count"];
        NSString *imagesString = [result stringForColumn:@"pic_urls"];
        
        if ([imagesString isKindOfClass:[NSString class]] && imagesString && ![imagesString isEqualToString:@""]) {
            twitterData.pic_urls = [imagesString componentsSeparatedByString:@","];
        }
        
        
        id userId = [result objectForColumnName:kUser];
        twitterData.user = [QYDataBaseEngine selectUser4ID:userId DB:db];
    }
    [result close];
    
    
    return twitterData;
}

//查询user
+(QYUser *)selectUser4ID:(id)userId DB:(FMDatabase *)db{
    NSString *sqlString = @"select * from user where id = %@";
    FMResultSet *result = [db executeQueryWithFormat:sqlString, userId];
    QYUser *user;
    if ([result next]) {
        user = [[QYUser alloc] init];
        //绑定属性
        user.userId = [result stringForColumn:@"id"];
        user.name = [result stringForColumn:@"name"];
        user.profile_image_url = [result stringForColumn:@"profile_image_url"];
    }
    [result close];
    return user;
}

@end
