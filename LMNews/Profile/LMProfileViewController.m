//
//  LMProfileViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMProfileViewController.h"
#import "LMProfileTableViewCell.h"
#import "LMMySubscriptionViewController.h"
#import "LMReadRecordViewController.h"
#import "LMMyCollectionViewController.h"
#import "LMMyMessageViewController.h"
#import "LMFeedBackViewController.h"
#import "LMAboutUsViewController.h"
#import "LMSystemSettingViewController.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMFastLoginViewController.h"
#import "LMProfileDetailViewController.h"
#import "LMHomeRightBarButtonItemView.h"

@interface LMProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIImageView* avatorIV;
@property (nonatomic, strong) UIButton* nickBtn;

@end

@implementation LMProfileViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@"我的订阅", @"阅读记录", @"我的收藏", @"我的消息", @"意见反馈", @"关于我们", @"系统设置", nil];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    CGFloat headerHeight = 160;
    if ([LMTool isIPhoneX]) {
        headerHeight = 200;
    }
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.avatorIV.userInteractionEnabled = YES;
    self.avatorIV.layer.cornerRadius = 25;
    self.avatorIV.layer.masksToBounds = YES;
    self.avatorIV.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2);
    self.avatorIV.image = [UIImage imageNamed:@"avator_LoginOut"];
    [headerView addSubview:self.avatorIV];
    
    self.nickBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    self.nickBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.nickBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.nickBtn setTitle:@"未登录" forState:UIControlStateNormal];
    [self.nickBtn addTarget:self action:@selector(clickedAvatorIV) forControlEvents:UIControlEventTouchUpInside];
    self.nickBtn.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2 + 40);
    [headerView addSubview:self.nickBtn];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedAvatorIV)];
    [self.avatorIV addGestureRecognizer:tap];
    
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* nick = @"未登录";
    LoginedRegUser* loginUser = [LMTool getLoginedRegUser];
    RegUser* user = loginUser.user;
    if (user != nil) {
        nick = user.phoneNum;
        if (user.nickname != nil && user.nickname.length > 0) {
            nick = user.nickname;
        }
        NSString* avator = user.icon;
        if (avator != nil && avator.length > 0) {
            [self.avatorIV sd_setImageWithURL:[NSURL URLWithString:avator] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
        }
    }else {
        self.avatorIV.image = [UIImage imageNamed:@"avator_LoginOut"];
    }
    
    [self.nickBtn setTitle:nick forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL hasUnread = [LMHomeRightBarButtonItemView hasUnreadMessage];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    LMProfileTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setupDotLabelHidden:!hasUnread];
}

//
-(void)clickedAvatorIV {
    LoginedRegUser* loginUser = [LMTool getLoginedRegUser];
    RegUser* user = loginUser.user;
    if (user != nil) {
        LMProfileDetailViewController* profileDetailVC = [[LMProfileDetailViewController alloc]init];
        profileDetailVC.loginedUser = [LMTool getLoginedRegUser];
        profileDetailVC.loginBlock = ^(BOOL isOutTime) {
            if (isOutTime) {
                LMFastLoginViewController* fastLoginVC = [[LMFastLoginViewController alloc]init];
//                fastLoginVC.userBlock = ^(LoginedRegUser *loginUser) {
//                    
//                };
                [self.navigationController pushViewController:fastLoginVC animated:YES];
            }
        };
        [self.navigationController pushViewController:profileDetailVC animated:YES];
    }else {
        LMFastLoginViewController* fastLoginVC = [[LMFastLoginViewController alloc]init];
        fastLoginVC.userBlock = ^(LoginedRegUser *loginUser) {
            
        };
        [self.navigationController pushViewController:fastLoginVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMProfileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString* str = [self.dataArray objectAtIndex:indexPath.row];
    cell.titleLab.text = str;
    
    if (indexPath.row == 3) {
        [cell setupDotLabelHidden:NO];
    }else {
        [cell setupDotLabelHidden:YES];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (row == 0) {
        LMMySubscriptionViewController* subscriptionVC = [[LMMySubscriptionViewController alloc]init];
        [self.navigationController pushViewController:subscriptionVC animated:YES];
    }else if (row == 1) {
        LMReadRecordViewController* recordVC = [[LMReadRecordViewController alloc]init];
        [self.navigationController pushViewController:recordVC animated:YES];
    }else if (row == 2) {
        LMMyCollectionViewController* collectionVC = [[LMMyCollectionViewController alloc]init];
        [self.navigationController pushViewController:collectionVC animated:YES];
    }else if (row == 3) {
        LMMyMessageViewController* messageVC = [[LMMyMessageViewController alloc]init];
        [self.navigationController pushViewController:messageVC animated:YES];
    }else if (row == 4) {
        LMFeedBackViewController* feedBackVC = [[LMFeedBackViewController alloc]init];
        [self.navigationController pushViewController:feedBackVC animated:YES];
    }else if (row == 5) {
        LMAboutUsViewController* aboutUsVC = [[LMAboutUsViewController alloc]init];
        [self.navigationController pushViewController:aboutUsVC animated:YES];
    }else if (row == 6) {
        LMSystemSettingViewController* systemSettingVC = [[LMSystemSettingViewController alloc]init];
        [self.navigationController pushViewController:systemSettingVC animated:YES];
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
