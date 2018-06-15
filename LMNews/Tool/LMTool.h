//
//  LMTool.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Qiwen.pb.h"

@interface LMTool : NSObject

//初始化第一次启动用户数据
+(void)initFirstLaunchData;

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser;

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser;

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser;

//删除用户信息
+(BOOL )deleteLoginedRegUser;

//是否第一次launch
+(BOOL )isFirstLaunch;

//删除启动次数
+(void)clearLaunchCount;

//启动次数+1
+(void)incrementLaunchCount;

//判断设备是否绑定
+(BOOL )deviceIsBinding;

//获取当前userId
+(NSString* )getAppUserId;


//iPhone X ?
+(BOOL )isIPhoneX;

//当前APP版本号（1.0.1）
+(NSString* )applicationCurrentVersion;

//protobuf device 设备信息
+(Device* )protobufDevice;

//10位时间戳，到秒
+(UInt32 )get10NumbersTimeStamp;

//将时间戳转换成标准时间
+(NSString *)convertTimeStringWithFormartterString:(NSString* )formatterStr TimeStamp:(NSInteger)timeStamp;

//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str;

//设置推送开光状态
+(void)setupUserNotificatioinState:(BOOL )isOpen;

//推送开光状态
+(BOOL )getUserNotificationState;

//根据颜色、尺寸生成图片
+(UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

//获取用户文件夹目录
+(NSString* )getUserFilePath;


//存储 启动页 数据
+(BOOL )saveLaunchImageData:(NSData* )launchData;
//删 启动页 数据
+(BOOL )deleteLaunchImageData;
//取 启动页 数据
+(NSData* )queryLaunchImageData;
//存 启动页 上次角标
+(void )saveLastLaunchImageIndex:(NSInteger )index;
//取 启动页 上次角标
+(NSInteger )queryLastLaunchImageIndex;
//删 启动页 上次角标
+(void )deleteLastLaunchImageIndex;

@end
