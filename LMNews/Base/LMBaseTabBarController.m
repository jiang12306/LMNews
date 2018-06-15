//
//  LMBaseTabBarController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTabBarController.h"
#import "LMHomeNewsViewController.h"
#import "LMExploreViewController.h"
#import "LMProfileViewController.h"
#import "LMBaseNavigationController.h"

@interface LMBaseTabBarController ()

@end

@implementation LMBaseTabBarController

-(instancetype)init {
    self = [super init];
    if (self) {
        NSArray* titleArr = @[@"刷新", @"探索", @"我的"];
        NSArray* imagesArr = @[@"tabBar_Home", @"tabBar_Explore", @"tabBar_Profile"];
        NSArray* selectedImagesArr = @[@"tabBar_Home_Selected", @"tabBar_Explore_Selected", @"tabBar_Profile_Selected"];
        
        LMHomeNewsViewController* newsVC = [[LMHomeNewsViewController alloc]init];
        UIImage* newsImage = [UIImage imageNamed:imagesArr[0]];
        UIImage* tintNewsImage = [newsImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UITabBarItem* newsBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[0] image:tintNewsImage tag:0];
        newsBarItem.selectedImage = [UIImage imageNamed:selectedImagesArr[0]];
        newsVC.tabBarItem = newsBarItem;
        
        LMExploreViewController* exploreVC = [[LMExploreViewController alloc]init];
        UIImage* exploreImage = [UIImage imageNamed:imagesArr[1]];
        UIImage* tintExploreImage = [exploreImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UITabBarItem* exploreBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[1] image:tintExploreImage tag:1];
        exploreBarItem.selectedImage = [UIImage imageNamed:selectedImagesArr[1]];
        exploreVC.tabBarItem = exploreBarItem;
        
        LMProfileViewController* profileVC = [[LMProfileViewController alloc]init];
        UIImage* profileImage = [UIImage imageNamed:imagesArr[2]];
        UIImage* tintProfileImage = [profileImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UITabBarItem* profileBarItem = [[UITabBarItem alloc]initWithTitle:titleArr[2] image:tintProfileImage tag:2];
        profileBarItem.selectedImage = [UIImage imageNamed:selectedImagesArr[2]];
        profileVC.tabBarItem = profileBarItem;
        
        LMBaseNavigationController* newsNVC = [[LMBaseNavigationController alloc]initWithRootViewController:newsVC];
        LMBaseNavigationController* exploreNVC = [[LMBaseNavigationController alloc]initWithRootViewController:exploreVC];
        LMBaseNavigationController* profileNVC = [[LMBaseNavigationController alloc]initWithRootViewController:profileVC];
        
        self.tabBar.tintColor = [UIColor colorWithHex:themeOrangeString];
        self.viewControllers = @[newsNVC, exploreNVC, profileNVC];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
