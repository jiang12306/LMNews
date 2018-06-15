//
//  LMFirstLaunchViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMFirstLaunchViewController.h"
#import "LMRootViewController.h"

@interface LMFirstLaunchViewController ()

@end

@implementation LMFirstLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView* iv = [[UIImageView alloc]initWithFrame:self.view.frame];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.image = [UIImage imageNamed:@"defaultFirstLaunch"];
    iv.userInteractionEnabled = YES;
    [self.view addSubview:iv];
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 3, 50)];
    btn.layer.cornerRadius = 10;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"立即进入" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 120);
}

-(void)startLogin:(UIButton* )sender {
    [[LMRootViewController sharedRootViewController] exchangeLaunchState:NO];
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
