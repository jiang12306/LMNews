//
//  LMDatabaseTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Qiwen.pb.h"

@interface LMDatabaseTool : NSObject

+(instancetype )sharedDatabaseTool;

//首次启动时创建数据表
-(void)createAllFirstLaunchTable;
//删除首次启动时创建的数据表
-(void)deleteAllFirstLaunchTable;





//文章记录 表

//创建
-(BOOL )createArticleTable;
//删除
-(BOOL )deleteArticleTable;
//判断文章是否已读
-(BOOL )isAlreadyReadArticleWithArticleId:(NSInteger )articleId;
//设置文章是否已读
-(BOOL )setArticleWithArticleId:(NSInteger )articleId isRead:(BOOL )isRead;


//专题记录 表

//创建
-(BOOL )createZhuanTiTable;
//删除
-(BOOL )deleteZhuanTiTable;
//判断专题是否已读
-(BOOL )isAlreadyReadZhuanTiWithZhuanTiId:(NSInteger )zhuanTiId;
//设置专题是否已读
-(BOOL )setZhuanTiWithZhuanTiId:(NSInteger )zhuanTiId isRead:(BOOL )isRead;

//删除超过指定天书的阅读记录
-(BOOL )deleteArticleAndZhuanTiOverDays:(NSInteger )days;

@end
