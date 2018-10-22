//
//  LMRootViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMRootViewController : UIViewController

+(instancetype )sharedRootViewController;

/** 更改启动根视图
 *  @param isFirstLaunch 是否第一次启动  YES：是   NO：否
 */
-(void)exchangeLaunchState:(BOOL)isFirstLaunch;

/** 当前vc跳转到任意VC
 *  @param purposeVC : 目标VC
 */
-(void)currentViewControllerPushToViewController:(UIViewController* )purposeVC;

/** 更改当前显示vc
 *  @param index 当前item的角标 0：主页  1：探索  2：我的
 */
-(void)setCurrentViewControllerIndex:(NSInteger )index;

/** 先回到根视图，然后跳转至vc
 *  @param classString 类型字符串
 *  @param paramString 传过来的参数
 */
-(void)openViewControllerCalss:(NSString* )classString paramString:(NSString* )paramString;


@end
