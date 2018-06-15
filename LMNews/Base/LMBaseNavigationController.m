//
//  LMBaseNavigationController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseNavigationController.h"
#import "LMTool.h"

@interface LMBaseNavigationController ()

@end

@implementation LMBaseNavigationController

-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        UIImage* img = [LMTool createImageWithColor:[UIColor whiteColor] size:CGSizeMake(screenRect.size.width, 100)];
        [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        
        //navigationBar底下不透明
        self.navigationBar.translucent = NO;
    }
    return self;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 30)];//12,24
        UIImage* image = [UIImage imageNamed:@"navigationItem_Back"];
        UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton* leftButton = [[UIButton alloc]initWithFrame:vi.frame];
        [leftButton setTintColor:[UIColor blackColor]];
        [leftButton setImage:tintImage forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 38)];
        [leftButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [vi addSubview:leftButton];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:vi];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
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
