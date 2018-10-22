//
//  AppDelegate.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "AppDelegate.h"
#import "LMRootViewController.h"
#import "LMTool.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import "WXApi.h"
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>
#import "LMShareMessage.h"
#import "LMNewsDetailViewController.h"
#import "LMLaunchImageView.h"

@interface AppDelegate () <JPUSHRegisterDelegate, WXApiDelegate>

@end

@implementation AppDelegate

//用户id，全局唯一标识，切换登录账号时跟着变
-(NSString *)userId {
    NSString* uuidStr = [LMTool getAppUserId];
    return uuidStr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //清理启动次数
    //    [LMTool clearLaunchCount];
    
    
    //初始化用户数据
    [LMTool initFirstLaunchData];
    
    
    //weChat
    //AppId:wxe4983e1c7d5dbb8c
    //AppSecret:64020361b8ec4c99936c0e3999a9f249
    [WXApi registerApp:weChatAppId];
    
    
    //QQ
    //AppId:101479744
    //AppKey:60bc86c88c70c5e52f71e5ce957db8de
    
    
    //UMent
    [UMConfigure setEncryptEnabled:YES];
    //    [UMConfigure setLogEnabled:NO];打包时必须设置为NO
    [MobClick setScenarioType:E_UM_NORMAL];
    [MobClick setCrashReportEnabled:YES];
    [UMConfigure initWithAppkey:@"5b1f96f1b27b0a0f93000034" channel:@"App Store"];
    
    
    //JPush
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:@"f3a329af85911b970c5cb80c" channel:@"App Store" apsForProduction:NO advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            NSLog(@"registrationID获取成功：%@",registrationID);
        }else {
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    
    UIWindow* window = [[UIWindow alloc]init];
    window.frame = [UIScreen mainScreen].bounds;
    window.backgroundColor = [UIColor whiteColor];
    self.window = window;
    
    LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
    
    if ([LMTool isFirstLaunch]) {
        self.window.rootViewController = rootVC;
        [self.window makeKeyAndVisible];
    }else {
        LMLaunchImageView* launchImageView = [[LMLaunchImageView alloc]init];
        launchImageView.callBlock = ^(BOOL isOver, NSString* openUrlStr) {
            if (isOver && openUrlStr != nil) {
                NSString* urlStr = openUrlStr;
                if ([urlStr rangeOfString:@"itunes.apple.com"].location != NSNotFound) {
                    NSString* encodeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:encodeUrl options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    }else {
                        [[UIApplication sharedApplication] openURL:encodeUrl];
                    }
                }else {
                    //打开广告页详情
                    [rootVC openViewControllerCalss:@"LMLaunchDetailViewController" paramString:urlStr];
                }
            }
        };
        self.window.rootViewController = rootVC;
        [self.window makeKeyAndVisible];
        [self.window addSubview:launchImageView];
    }

    
    //增加统计次数
    [LMTool incrementLaunchCount];
    
    
    return YES;
}


#pragma mark -WXApiDelegate
-(void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {//登录
        SendAuthResp* authResp = (SendAuthResp* )resp;
        if ([authResp.state isEqualToString:weChatLoginState] && authResp.errCode == 0) {
            NSString* codeStr = authResp.code;
            //发通知
            NSDictionary* infoDic = @{weChatLoginKey: codeStr};
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatLoginNotifyName object:nil userInfo:infoDic];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatLoginNotifyName object:nil userInfo:nil];
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {//分享
        SendMessageToWXResp* wxResp = (SendMessageToWXResp* )resp;
        if (wxResp.errCode == 0) {
            NSDictionary* infoDic = @{weChatShareKey : [NSNumber numberWithBool:YES]};
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:infoDic];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:nil];
        }
    }
}


//iOS  9.0 before
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"11111111111url : %@",url);
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
//    [QQApiInterface handleOpenURL:url delegate:self];
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"22222222222url : %@",url);
    
    NSLog(@"sourceApplication : %@",sourceApplication);
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
//    [QQApiInterface handleOpenURL:url delegate:self];
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    return YES;
}

//iOS 9.0 later
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    NSLog(@"333333333333url : %@",url);
    
    if (@available(iOS 9.0, *)) {
        NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
        NSLog(@"sourceApplication : %@",sourceApplication);
    }
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
//    [QQApiInterface handleOpenURL:url delegate:self];
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //
    [LMTool setupUserNotificatioinState:YES];
    
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //
    [LMTool setupUserNotificatioinState:NO];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^) (UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    /*
    @try {
        NSDictionary* userInfoDic = content.userInfo;
        if (userInfoDic != nil && ![userInfoDic isKindOfClass:[NSNull class]] && userInfoDic.count > 0) {
            NSNumber* num = [userInfoDic objectForKey:@"newsId"];
            NSString* newsIdStr = [NSString stringWithFormat:@"%@", num];
            
            if (newsIdStr != nil && ![newsIdStr isKindOfClass:[NSNull class]] && newsIdStr.length > 0) {
                LMNewsDetailViewController* detailVC = [[LMNewsDetailViewController alloc]init];
                detailVC.newsId = newsIdStr.integerValue;
                [[LMRootViewController sharedRootViewController]currentViewControllerPushToViewController:detailVC];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    */
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request;
     // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    @try {
        NSDictionary* userInfoDic = content.userInfo;
        if (userInfoDic != nil && ![userInfoDic isKindOfClass:[NSNull class]] && userInfoDic.count > 0) {
            NSNumber* num = [userInfoDic objectForKey:@"newsId"];
            NSString* newsIdStr = [NSString stringWithFormat:@"%@", num];
            
            if (newsIdStr != nil && ![newsIdStr isKindOfClass:[NSNull class]] && newsIdStr.length > 0) {
                LMNewsDetailViewController* detailVC = [[LMNewsDetailViewController alloc]init];
                detailVC.newsId = newsIdStr.integerValue;
                [[LMRootViewController sharedRootViewController]currentViewControllerPushToViewController:detailVC];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [JPUSHService resetBadge];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
