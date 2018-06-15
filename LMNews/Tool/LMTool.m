//
//  LMTool.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMTool.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AppDelegate.h"

@implementation LMTool

static NSString* launchCount = @"launchCount";
static NSString* currentUserId = @"currentUserId";

//初始化第一次启动用户数据
+(void)initFirstLaunchData {
    //创建用户文件夹
    [LMTool getUserFilePath];
    
    
    //创建 表
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool createAllFirstLaunchTable];
    
}

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser {
    LoginedRegUserBuilder* builder = [LoginedRegUser builder];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath]) {
        return nil;
    }
    
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString* tokenStr = [dic objectForKey:@"token"];
    NSString* uidStr = [dic objectForKey:@"uid"];
    NSString* phoneNumStr = [dic objectForKey:@"phoneNum"];
    NSString* emailStr = [dic objectForKey:@"email"];
    NSNumber* genderNum = [dic objectForKey:@"gender"];
    NSInteger genderInt = [genderNum integerValue];
    GenderType type = GenderTypeGenderUnknown;
    if (genderInt == 1) {
        type = GenderTypeGenderMale;
    }else if (genderInt == 2) {
        type = GenderTypeGenderFemale;
    }else if (genderInt == 3) {
        type = GenderTypeGenderOther;
    }
    NSString* birthdayStr = [dic objectForKey:@"birthday"];
    NSString* localAreaStr = [dic objectForKey:@"localArea"];
    NSNumber* registerTimeNum = [dic objectForKey:@"registerTime"];
    NSString* iconStr = [dic objectForKey:@"icon"];
    NSString* wxStr = [dic objectForKey:@"wx"];
    NSString* qqStr = [dic objectForKey:@"qq"];
    NSNumber* setpwNum = [dic objectForKey:@"setpw"];
    RegUserSetPw setPw = RegUserSetPwNo;
    if (setpwNum.integerValue == 1) {
        setPw = RegUserSetPwYes;
    }
    NSData* avatorData = [dic objectForKey:@"avator"];
    NSString* nickNameStr = [dic objectForKey:@"nickName"];
    NSString* wxNickNameStr = [dic objectForKey:@"wxNickName"];
    NSString* qqNickNameStr = [dic objectForKey:@"qqNickName"];
    
    RegUserBuilder* userBuilder = [RegUser builder];
    [userBuilder setUid:uidStr];
    [userBuilder setPhoneNum:phoneNumStr];
    [userBuilder setEmail:emailStr];
    [userBuilder setGender:type];
    [userBuilder setBirthday:birthdayStr];
    [userBuilder setLocalArea:localAreaStr];
    [userBuilder setRegisterTime:(UInt32)[registerTimeNum intValue]];
    [userBuilder setIcon:iconStr];
    [userBuilder setWx:wxStr];
    [userBuilder setQq:qqStr];
    [userBuilder setSetpw:setPw];
    [userBuilder setNickname:nickNameStr];
    [userBuilder setWxNickname:wxNickNameStr];
    [userBuilder setQqNickname:qqNickNameStr];
    [userBuilder setIconB:avatorData];
    RegUser* regUser = [userBuilder build];
    
    [builder setToken:tokenStr];
    [builder setUser:regUser];
    
    LoginedRegUser* user = [builder build];
    return user;
}

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser {
    NSString* userId = loginUser.user.uid;
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([LMTool deviceIsBinding]) {//设备已经被绑定过
        NSString* bindUserId = [LMTool getAppUserId];
        if ([bindUserId isEqualToString:uuidStr]) {//设备绑定的是当前账号
            return;
        }
        
        //根据用户id来创建用户目录文件夹、设置APPDelegate.userId、创建数据表
        
        [defaults setObject:userId forKey:currentUserId];
        [defaults synchronize];
        
        //初始化用户数据
        [LMTool initFirstLaunchData];
        
        //To Do...
        
    }else {
        [defaults setObject:userId forKey:uuidStr];
        [defaults setObject:uuidStr forKey:currentUserId];
        [defaults synchronize];
    }
    
}

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser {
    NSString* token = loginedUser.token;
    RegUser* regUser = loginedUser.user;
    NSString* uidStr = regUser.uid;
    NSString* phoneNumStr = regUser.phoneNum;
    NSString* emailStr = regUser.email;
    GenderType genderType = regUser.gender;
    NSNumber* genderNum = @0;
    if (genderType == GenderTypeGenderMale) {
        genderNum = @1;
    }else if (genderType == GenderTypeGenderFemale) {
        genderNum = @2;
    }else if (genderType == GenderTypeGenderOther) {
        genderNum = @3;
    }
    NSString* birthdayStr = regUser.birthday;
    NSString* localAreaStr = regUser.localArea;
    UInt32 registerTimeInt = regUser.registerTime;
    NSNumber* registerTimeNum = [NSNumber numberWithInt:registerTimeInt];
    NSString* iconStr = regUser.icon;
    NSString* wxStr = regUser.wx;
    NSString* qqStr = regUser.qq;
    RegUserSetPw setpw = regUser.setpw;
    NSNumber* setpwNum = @0;
    if (setpw == RegUserSetPwYes) {
        setpwNum = @1;
    }
    NSData* avatorData = regUser.iconB;
    NSString* nickNameStr = regUser.nickname;
    NSString* wxNickNameStr = regUser.wxNickname;
    NSString* qqNickNameStr = regUser.qqNickname;
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:token forKey:@"token"];
    [dic setObject:uidStr forKey:@"uid"];
    [dic setObject:phoneNumStr forKey:@"phoneNum"];
    [dic setObject:emailStr forKey:@"email"];
    [dic setObject:genderNum forKey:@"gender"];
    [dic setObject:birthdayStr forKey:@"birthday"];
    [dic setObject:localAreaStr forKey:@"localArea"];
    [dic setObject:registerTimeNum forKey:@"registerTime"];
    [dic setObject:iconStr forKey:@"icon"];
    [dic setObject:wxStr forKey:@"wx"];
    [dic setObject:qqStr forKey:@"qq"];
    [dic setObject:setpwNum forKey:@"setpw"];
    [dic setObject:nickNameStr forKey:@"nickName"];
    [dic setObject:wxNickNameStr forKey:@"wxNickName"];
    [dic setObject:qqNickNameStr forKey:@"qqNickName"];
    [dic setObject:avatorData forKey:@"avator"];
    
    //
    [dic writeToFile:plistPath atomically:YES];
}

//删除用户信息
+(BOOL )deleteLoginedRegUser {
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    if ([fileManager fileExistsAtPath:plistPath]) {
        [fileManager removeItemAtPath:plistPath error:&error];
    }
    if (error) {
        return NO;
    }
    return YES;
}

//是否第一次launch
+(BOOL)isFirstLaunch {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
    if (count == nil) {
        return YES;
    }
    if ([count isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (count.integerValue == 0) {
        return YES;
    }
    return NO;
}

//删除启动次数
+(void)clearLaunchCount {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:keyStr];
    [defaults synchronize];
}

//启动次数+1
+(void)incrementLaunchCount {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSInteger countInteger = 0;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
    if (count != nil && [count isKindOfClass:[NSNull class]]) {
        countInteger = [count integerValue];
    }
    countInteger ++;
    
    [defaults setObject:[NSNumber numberWithInteger:countInteger] forKey:keyStr];
    [defaults synchronize];
}

//判断设备是否绑定
+(BOOL )deviceIsBinding {
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [defaults objectForKey:uuidStr];
    if (userId != nil && ![userId isKindOfClass:[NSNull class]] && userId.length > 0) {
        return YES;
    }
    return NO;
}

//获取当前userId
+(NSString* )getAppUserId {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([LMTool deviceIsBinding]) {
        NSString* userId = [defaults objectForKey:currentUserId];
        return userId;
    }else {
        NSString* uuidStr = [LMTool uuid];
        uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        return uuidStr;
    }
}

//uuid
+(NSString* )uuid {
    NSString* uuidStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuidStr;
}

//iPhone X ?
+(BOOL )isIPhoneX {
    CGRect rect = CGRectMake(0, 0, 375, 812);
    CGRect deviceRect = [UIScreen mainScreen].bounds;
    return CGRectEqualToRect(deviceRect, rect);
}

//当前APP版本号（1.0.1）
+(NSString* )applicationCurrentVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appCurVersion;
}

//系统版本
+(NSString* )systemVersion {
    NSString* systemStr = [[UIDevice currentDevice] systemVersion];
    return systemStr;
}

//设备型号
+(NSString* )deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

+(DeviceUdId* )protobufDeviceUuId {
    DeviceUdIdBuilder* builder = [DeviceUdId builder];
    [builder setUuid:[LMTool uuid]];
    return [builder build];
}

+(DeviceSize* )protobufDeviceSize {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    DeviceSizeBuilder* builder = [DeviceSize builder];
    [builder setWidth: (UInt32)screenRect.size.width];
    [builder setHeight:(UInt32)screenRect.size.height];
    return [builder build];
}

+(Device* )protobufDevice {
    DeviceDeviceType type = DeviceDeviceTypeDevicePhone;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        type = DeviceDeviceTypeDevicePhone;
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        type = DeviceDeviceTypeDeviceTablet;
    }else {
        type = DeviceDeviceTypeDeviceUnknown;
    }
    DeviceBuilder* devideBuild = [Device builder];
    [devideBuild setDeviceType:type];
    [devideBuild setOsType:DeviceOsTypeIos];
    [devideBuild setOsVersion:[LMTool systemVersion]];
    [devideBuild setVendor:[@"Apple" dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setModel:[[LMTool deviceModel] dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setUdid:[LMTool protobufDeviceUuId]];
    [devideBuild setScreenSize:[LMTool protobufDeviceSize]];
    
    return [devideBuild build];
}

//10位时间戳，到秒
+(UInt32 )get10NumbersTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return (UInt32 )[timeString integerValue];
}

//将时间戳转换成标准时间
+(NSString *)convertTimeStringWithFormartterString:(NSString* )formatterStr TimeStamp:(NSInteger)timeStamp {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:formatterStr];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString* str = [stampFormatter stringFromDate:stampDate];
    return str;
}

//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str {
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

//设置推送开光状态
+(void)setupUserNotificatioinState:(BOOL )isOpen {
    NSString* userIdStr = [NSString stringWithFormat:@"%@_Notification", [LMTool getAppUserId]];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:isOpen forKey:userIdStr];
    [userDefault synchronize];
}

//推送开光状态
+(BOOL )getUserNotificationState {
    NSString* userIdStr = [NSString stringWithFormat:@"%@_Notification", [LMTool getAppUserId]];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault boolForKey:userIdStr];
}

//根据颜色、尺寸生成图片
+(UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

//获取用户文件夹目录
+(NSString* )getUserFilePath {
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* userFilePath = [documentPath stringByAppendingPathComponent:[LMTool getAppUserId]];
    BOOL isDir;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFilePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:userFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* bookRecordPath = [documentPath stringByAppendingPathComponent:@"Article"];//书本记录 文件夹
    BOOL isBookDir;
    if (![fileManager fileExistsAtPath:bookRecordPath isDirectory:&isBookDir]) {//不存在文件夹 创建
        [fileManager createDirectoryAtPath:bookRecordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return userFilePath;
}

//存储 启动页 数据
+(BOOL )saveLaunchImageData:(NSData* )launchData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        [fileManager removeItemAtPath:launchPath error:nil];
    }
    BOOL result = [launchData writeToFile:launchPath atomically:YES];
    return result;
}
//删 启动页 数据
+(BOOL )deleteLaunchImageData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        return [fileManager removeItemAtPath:launchPath error:nil];
    }
    return NO;
}
//取 启动页 数据
+(NSData* )queryLaunchImageData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        NSData* data = [[NSData alloc]initWithContentsOfFile:launchPath];
        return data;
    }else {
        return nil;
    }
}
//存 启动页 上次角标
+(void )saveLastLaunchImageIndex:(NSInteger )index {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInteger:index] forKey:@"launchDataIndex"];
    [userDefaults synchronize];
}
//取 启动页 上次角标
+(NSInteger )queryLastLaunchImageIndex {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* num = [userDefaults objectForKey:@"launchDataIndex"];
    if (num != nil && ![num isKindOfClass:[NSNull class]]) {
        return num.integerValue;
    }else {
        return 0;
    }
}
//删 启动页 上次角标
+(void )deleteLastLaunchImageIndex {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"launchDataIndex"];
    [userDefaults synchronize];
}


@end
