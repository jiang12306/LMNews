//
//  LMDatabaseTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMDatabaseTool.h"
#import "FMDB.h"
#import "LMTool.h"

@implementation LMDatabaseTool

static LMDatabaseTool *_sharedDatabaseTool;
static dispatch_once_t onceToken;
static NSString* databaseName = @"article.db";

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (_sharedDatabaseTool == nil) {
            _sharedDatabaseTool = [super allocWithZone:zone];
        }
    });
    return _sharedDatabaseTool;
}

-(id)copyWithZone:(NSZone *)zone {
    return _sharedDatabaseTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedDatabaseTool;
}

+(instancetype)sharedDatabaseTool {
    if (_sharedDatabaseTool) {
        return _sharedDatabaseTool;
    }
    return [[self alloc]init];
}

//首次启动时创建数据表
-(void)createAllFirstLaunchTable {
    [self createArticleTable];
    [self createZhuanTiTable];
}

//删除首次启动时创建的数据表
-(void)deleteAllFirstLaunchTable {
    [self deleteArticleTable];
    [self deleteZhuanTiTable];
}

//获取当前时间date
-(NSDate* )getCurrentDate {
    //获取系统时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //获取系统时区 **此时不设置时区是默认为系统时区
    formatter.timeZone = [NSTimeZone systemTimeZone];
    //指定时间显示样式: HH表示24小时制 hh表示12小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //只显示时间
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
    //只显示日期
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSDate* date = [formatter dateFromString:dateStr];
    
    return date;
}

//获取xx天前时间date
-(NSDate* )getDateOverDays:(NSInteger )dayInt {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:(0 - dayInt)];
    NSDate *date30DaysAgo = [calendar dateByAddingComponents:dateComps toDate:currentDate options:0];
    return date30DaysAgo;
}


//获取数据库文件路径
-(NSString *)getDatabasePath {
    NSString* userFilePath = [LMTool getUserFilePath];//用户文件夹目录
    NSString *dbPath = [userFilePath stringByAppendingPathComponent:databaseName];
    return dbPath;
}



#define DatabaseId @"dbid"


//文章记录 表
#define Article_table_name @"ArticleTable"
#define Article_id @"ArticleId"
#define Article_ReadState @"ArticleReadState"
#define Article_time @"ArticleTime"

//创建
-(BOOL )createArticleTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer not null unique, %@ integer, %@ datetime)", Article_table_name, DatabaseId, Article_id, Article_ReadState, Article_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteArticleTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Article_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//判断文章是否已读
-(BOOL )isAlreadyReadArticleWithArticleId:(NSInteger )articleId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        res = NO;
        NSNumber* articleIdNum = [NSNumber numberWithInteger:articleId];
        NSString* selectSQL = [NSString stringWithFormat:@"select * from %@ where %@ = ?", Article_table_name, Article_id];
        FMResultSet* rs = [db executeQuery:selectSQL, articleIdNum];
        while ([rs next]) {
            res = YES;
            break;
        }
    }
    [db close];
    return res;
}

//设置文章是否已读
-(BOOL )setArticleWithArticleId:(NSInteger )articleId isRead:(BOOL )isRead {
    NSDate* currentDate = [self getCurrentDate];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* articleIdNumber = [NSNumber numberWithInteger:articleId];
        NSNumber* readNumber = [NSNumber numberWithBool:isRead];
        
        NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@) values (?, ?, ?);", Article_table_name, Article_id, Article_ReadState, Article_time];
        
        res = [db executeUpdate:sql, articleIdNumber, readNumber, currentDate];
    }
    [db close];
    return res;
}



//专题记录 表
#define ZhuanTi_table_name @"ZhuanTiTable"
#define ZhuanTi_id @"ZhuanTiId"
#define ZhuanTi_ReadState @"ZhuanTiReadState"
#define ZhuanTi_time @"ZhuanTiTime"

//创建
-(BOOL )createZhuanTiTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer not null unique, %@ integer, %@ datetime)", ZhuanTi_table_name, DatabaseId, ZhuanTi_id, ZhuanTi_ReadState, ZhuanTi_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}
//删除
-(BOOL )deleteZhuanTiTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", ZhuanTi_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}
//判断专题是否已读
-(BOOL )isAlreadyReadZhuanTiWithZhuanTiId:(NSInteger )zhuanTiId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        res = NO;
        NSNumber* articleIdNum = [NSNumber numberWithInteger:zhuanTiId];
        NSString* selectSQL = [NSString stringWithFormat:@"select * from %@ where %@ = ?", ZhuanTi_table_name, ZhuanTi_id];
        FMResultSet* rs = [db executeQuery:selectSQL, articleIdNum];
        while ([rs next]) {
            res = YES;
            break;
        }
    }
    [db close];
    return res;
}
//设置专题是否已读
-(BOOL )setZhuanTiWithZhuanTiId:(NSInteger )zhuanTiId isRead:(BOOL )isRead {
    NSDate* currentDate = [self getCurrentDate];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* zhuanTiIdNumber = [NSNumber numberWithInteger:zhuanTiId];
        NSNumber* readNumber = [NSNumber numberWithBool:isRead];
        
        NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@) values (?, ?, ?);", ZhuanTi_table_name, ZhuanTi_id, ZhuanTi_ReadState, ZhuanTi_time];
        
        res = [db executeUpdate:sql, zhuanTiIdNumber, readNumber, currentDate];
    }
    [db close];
    return res;
}

//删除超过指定天书的阅读记录
-(BOOL )deleteArticleAndZhuanTiOverDays:(NSInteger )days {
    NSDate* daysOver30 = [self getDateOverDays:days];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ < ?;", Article_table_name, Article_time];
        res = [db executeUpdate:sql, daysOver30];
        
        NSString* sql2 = [NSString stringWithFormat:@"delete from %@ where %@ < ?;", ZhuanTi_table_name, ZhuanTi_time];
        res = [db executeUpdate:sql2, daysOver30];
    }
    [db close];
    return res;
}





@end
