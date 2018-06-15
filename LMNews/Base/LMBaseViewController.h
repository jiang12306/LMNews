//
//  LMBaseViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Qiwen.pb.h"
#import "LMNetworkTool.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface LMBaseViewController : UIViewController

//显示 网络加载
-(void)showNetworkLoadingView;
//隐藏 网络加载
-(void)hideNetworkLoadingView;

//MBProgressHUD
-(void)showMBProgressHUDWithText:(NSString* )hudText;

//显示 刷新按钮
-(void)showReloadButton;
//隐藏 刷新按钮
-(void)hideReloadButton;
//点击 刷新按钮
-(void)clickedSelfReloadButton:(UIButton* )sender;

//显示 无数据
-(void)showEmptyLabelWithText:(NSString* )emptyText;
//隐藏 无数据
-(void)hideEmptyLabel;

@end
