//
//  LMMyMessageViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMyMessageViewController.h"
#import "LMMySystemMessageTableViewCell.h"
#import "LMMyFollowMessageTableViewCell.h"
#import "LMMyMessageModel.h"
#import "LMMySystemMessageDetailViewController.h"
#import "LMMySystemMessageViewController.h"
#import "LMMyFollowMessageViewController.h"

@interface LMMyMessageViewController ()

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIButton* systemMsgBtn;/**<系统消息*/
@property (nonatomic, strong) UIButton* followMsgBtn;/**<跟进评论*/
@property (nonatomic, assign) NSInteger btnIndex;/**<0：系统消息；1：跟进评论*/

@end

@implementation LMMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的消息";
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    CGFloat btnWidth = 80;
    CGFloat btnHeight = 40;
    self.systemMsgBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - btnWidth - 10, 10, btnWidth, btnHeight)];
    self.systemMsgBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.systemMsgBtn setTitle:@"系统消息" forState:UIControlStateNormal];
    [self.systemMsgBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    [self.systemMsgBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.systemMsgBtn];
    
    UIView* lineVi = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 3, 20)];
    lineVi.backgroundColor = [UIColor blackColor];
    [self.headerView addSubview:lineVi];
    lineVi.center = CGPointMake(self.headerView.frame.size.width / 2, self.headerView.frame.size.height / 2);
    
    self.followMsgBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 10, btnWidth, btnHeight)];
    self.followMsgBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.followMsgBtn setTitle:@"跟进评论" forState:UIControlStateNormal];
    [self.followMsgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followMsgBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.followMsgBtn];
    
    [self.view addSubview:self.headerView];
    
    
    //
    [self createSystemMessageViewController];
}

-(void)clickedOrderButton:(UIButton* )sender {
    if (sender == self.systemMsgBtn) {
        if (self.btnIndex == 1) {
            [self.followMsgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.systemMsgBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            self.btnIndex = 0;
            //
            BOOL isContain = NO;
            UIViewController* containVC = nil;
            for (UIViewController* vc in self.childViewControllers) {
                if ([vc isKindOfClass:[LMMySystemMessageViewController class]]) {
                    isContain = YES;
                    containVC = vc;
                }else if ([vc isKindOfClass:[LMMyFollowMessageViewController class]]) {
                    [self.view sendSubviewToBack:vc.view];
                }
            }
            if (!isContain) {
                [self createSystemMessageViewController];
            }
        }
    }else if (sender == self.followMsgBtn) {
        if (self.btnIndex == 0) {
            [self.followMsgBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            [self.systemMsgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.btnIndex = 1;
            //
            BOOL isContain = NO;
            UIViewController* containVC = nil;
            for (UIViewController* vc in self.childViewControllers) {
                if ([vc isKindOfClass:[LMMyFollowMessageViewController class]]) {
                    isContain = YES;
                    containVC = vc;
                }else if ([vc isKindOfClass:[LMMySystemMessageViewController class]]) {
                    [self.view sendSubviewToBack:vc.view];
                }
            }
            if (!isContain) {
                [self createFollowMessageViewController];
            }
        }
    }
}

-(void)createSystemMessageViewController {
    LMMySystemMessageViewController* systemMsgVC = [[LMMySystemMessageViewController alloc]init];
    systemMsgVC.topY = self.headerView.frame.size.height;
    [self addChildViewController:systemMsgVC];
    [self.view insertSubview:systemMsgVC.view belowSubview:self.headerView];
}

-(void)createFollowMessageViewController {
    LMMyFollowMessageViewController* followMsgVC = [[LMMyFollowMessageViewController alloc]init];
    followMsgVC.topY = self.headerView.frame.size.height;
    [self addChildViewController:followMsgVC];
    [self.view insertSubview:followMsgVC.view belowSubview:self.headerView];
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
