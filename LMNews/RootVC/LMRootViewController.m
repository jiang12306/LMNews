//
//  LMRootViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRootViewController.h"
#import "LMFirstLaunchViewController.h"
#import "LMBaseTabBarController.h"
#import "LMTool.h"
#import "LMBaseNavigationController.h"
#import "LMLaunchDetailViewController.h"

@interface LMRootViewController () <UITabBarControllerDelegate>

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation LMRootViewController

static LMRootViewController *sharedVC;
static dispatch_once_t onceToken;

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (sharedVC == nil) {
            sharedVC = [super allocWithZone:zone];
        }
    });
    return sharedVC;
}

-(id)copyWithZone:(NSZone *)zone {
    return sharedVC;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return sharedVC;
}

+(instancetype)sharedRootViewController {
    return [[self alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self exchangeLaunchState:[LMTool isFirstLaunch]];
}

-(void)exchangeLaunchState:(BOOL)isFirstLaunch {
    BOOL isContain = NO;
    if (isFirstLaunch) {//第一次启动
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMFirstLaunchViewController class]]) {
                isContain = YES;
                break;
            }else if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
        if (!isContain) {
            LMFirstLaunchViewController* firstLaunchVC = [[LMFirstLaunchViewController alloc]init];
            [self addChildViewController:firstLaunchVC];
            [self.view addSubview:firstLaunchVC.view];
        }
    }else {
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
                isContain = YES;
                break;
            }else if ([vc isKindOfClass:[LMFirstLaunchViewController class]]) {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
        if (!isContain) {
            LMBaseTabBarController* barController = [[LMBaseTabBarController alloc]init];
            barController.delegate = self;
            [self addChildViewController:barController];
            [self.view addSubview:barController.view];
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSInteger selectedIndex = tabBarController.selectedIndex;
    if (selectedIndex != 0) {
        @try {
            UIViewController* vc = [tabBarController.viewControllers objectAtIndex:0];
            UITabBarItem* item = vc.tabBarItem;
            [item setTitle:@"主页"];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }else {
        @try {
            UIViewController* vc = [tabBarController.viewControllers objectAtIndex:0];
            UITabBarItem* item = vc.tabBarItem;
            [item setTitle:@"刷新"];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    if (self.currentIndex == 0) {
        if (selectedIndex == 0) {
            @try {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"clickedTabBarRefresh" object:nil];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
    self.currentIndex = selectedIndex;
}

-(void)currentViewControllerPushToViewController:(UIViewController* )purposeVC {
    @try {
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
                LMBaseTabBarController* tabBarController = (LMBaseTabBarController* )vc;
                NSArray* vcArr = tabBarController.viewControllers;
                LMBaseNavigationController* naviController = [vcArr objectAtIndex:self.currentIndex];
                [naviController pushViewController:purposeVC animated:YES];
                
                break;
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

//更改当前显示vc
-(void)setCurrentViewControllerIndex:(NSInteger)index {
    LMBaseTabBarController* tabBarController;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            break;
        }
    }
    if (tabBarController && index < tabBarController.viewControllers.count) {
        tabBarController.selectedIndex = index;
    }
}

//跳转至vc
-(void)openViewControllerCalss:(NSString* )classString paramString:(NSString* )paramString {
    LMBaseTabBarController* tabBarController;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMBaseTabBarController class]]) {
            tabBarController = (LMBaseTabBarController* )vc;
            for (UIViewController* vc in tabBarController.viewControllers) {
                LMBaseNavigationController* nvc = (LMBaseNavigationController* )vc;
                [nvc popToRootViewControllerAnimated:NO];
            }
            break;
        }
    }
    if (tabBarController.viewControllers.count > 0) {
        
        Class class = NSClassFromString(classString);
        
        if ([classString isEqualToString:@"LMLaunchDetailViewController"]) {
            [self setCurrentViewControllerIndex:0];
            LMLaunchDetailViewController* vc = [class new];
            if (paramString != nil && ![paramString isKindOfClass:[NSNull class]]) {
                vc.urlString = paramString;
            }
            LMBaseNavigationController* homeNVC = [tabBarController.viewControllers objectAtIndex:0];
            [homeNVC pushViewController:vc animated:YES];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
