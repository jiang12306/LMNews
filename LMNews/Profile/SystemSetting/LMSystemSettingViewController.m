//
//  LMSystemSettingViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSystemSettingViewController.h"
#import "LMSystemSettingTableViewCell.h"
#import "LMTool.h"
#import "SDWebImageManager.h"

@interface LMSystemSettingViewController () <UITableViewDelegate, UITableViewDataSource, LMSystemSettingTableViewCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, assign) NSUInteger memoryInt;
@property (nonatomic, assign) BOOL isAlert;

@end

@implementation LMSystemSettingViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"系统设置";
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMSystemSettingTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        UIButton* loginOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 50, footerView.frame.size.width - 10 * 2, 50)];
        loginOutBtn.backgroundColor = [UIColor colorWithRed:40/255.f green:194/255.f blue:30/255.f alpha:1];
        loginOutBtn.layer.cornerRadius = 5;
        loginOutBtn.layer.masksToBounds = YES;
        loginOutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [loginOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginOutBtn addTarget:self action:@selector(clickedLoginOutButton:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:loginOutBtn];
        
        self.tableView.tableFooterView = footerView;
    }

    self.memoryInt = 0;
    self.isAlert = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        SDImageCache* imageCache = manager.imageCache;
        self.memoryInt += [imageCache getSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSArray* arr = @[indexpath];
            [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"清理缓存", @"通知提醒", nil];
    [self.tableView reloadData];
}

//退出登录
-(void)clickedLoginOutButton:(UIButton* )sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"userDidLoginOut" object:nil userInfo:nil];
    
    //删除用户数据
    [LMTool deleteLoginedRegUser];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMSystemSettingTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMSystemSettingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    cell.nameLab.text = [self.titleArray objectAtIndex:row];
    if (row == 0) {//清理缓存
        cell.contentSwitch.hidden = YES;
        cell.contentLab.hidden = NO;
        
        cell.contentLab.text = [NSString stringWithFormat:@"%.2fMB", ((float)self.memoryInt)/1024/1024];
    }else {
        cell.contentSwitch.hidden = NO;
        cell.contentLab.hidden = YES;
        cell.contentSwitch.on = YES;
        
        BOOL notifyState = [LMTool getUserNotificationState];
        [cell.contentSwitch setOn:notifyState];
    }
    cell.delegate = self;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (row == 0) {
        [self showNetworkLoadingView];
        
        //
        [[LMDatabaseTool sharedDatabaseTool]deleteArticleAndZhuanTiOverDays:30];
        
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        SDImageCache* imageCache = manager.imageCache;
        [imageCache clearMemory];
        [imageCache clearDiskOnCompletion:^{
            self.memoryInt = 0;
            LMSystemSettingTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.contentLab.text = [NSString stringWithFormat:@"%.2fMB", ((float)self.memoryInt)/1024/1024];
            
            [self hideNetworkLoadingView];
            
            [self showMBProgressHUDWithText:@"清理完成"];
        }];
    }
}

#pragma mark -LMSystemSettingTableViewCellDelegate
-(void)didClickSwitch:(BOOL)isOn systemSettingCell:(LMSystemSettingTableViewCell *)cell {
    self.isAlert = isOn;
    cell.contentSwitch.on = self.isAlert;
    
    
    //
    [LMTool setupUserNotificatioinState:isOn];
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
