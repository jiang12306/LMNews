//
//  LMMySubscriptionViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMySubscriptionViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMMySubscriptionTableViewCell.h"
#import "LMMediaDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMLoginAlertView.h"

@interface LMMySubscriptionViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate, LMMySubscriptionTableViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, assign) NSInteger page;

@end

@implementation LMMySubscriptionViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的订阅";
    
    CGFloat naviBarHeight = 64;
    if ([LMTool isIPhoneX]) {
        naviBarHeight = 88;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviBarHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMMySubscriptionTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    self.dataArray = [NSMutableArray array];
    self.page = 0;
    self.isEnd = NO;
    [self loadMySubscriptionDataWithPage:self.page isLoadMore:NO];
}

-(void)loadMySubscriptionDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    MySubReqBuilder* builder = [MySubReq builder];
    [builder setPage:(UInt32 )page];
    MySubReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:25 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 25) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    MySubRes* res = [MySubRes parseFromData:apiRes.body];
                    
                    UInt32 pSize = res.psize;
                    NSArray* arr = res.sources;
                    if (arr == nil || arr.count <= pSize) {//最后一页
                        [self.tableView setupNoMoreData];
                        self.isEnd = YES;
                    }
                    
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        
                        [self.dataArray addObjectsFromArray:arr];
                    }
                    if (self.page == 0 && self.dataArray.count == 0) {
                        [self showEmptyLabelWithText:nil];
                    }else {
                        [self hideEmptyLabel];
                    }
                    [self hideReloadButton];
                    
                    self.page ++;
                    
                    [self.tableView reloadData];
                    
                }else if (err == ErrCodeErrNotlogined) {
                    [self showMBProgressHUDWithText:@"尚未登录"];
                }
            }
        } @catch (NSException *exception) {
            [self showMBProgressHUDWithText:NetworkFailedError];
            
            if (self.dataArray.count == 0) {
                [self showReloadButton];
            }
        } @finally {
            if (isLoadMore) {
                [self.tableView stopLoadMoreData];
            }else {
                [self.tableView stopRefresh];
            }
            [self hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [self showMBProgressHUDWithText:NetworkFailedError];
        if (isLoadMore) {
            [self.tableView stopLoadMoreData];
        }else {
            [self.tableView stopRefresh];
        }
        [self hideNetworkLoadingView];
        
        if (self.dataArray.count == 0) {
            [self showReloadButton];
        }
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self.tableView startRefresh];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
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
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMMySubscriptionTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMMySubscriptionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Source* tempSource = [self.dataArray objectAtIndex:indexPath.row];
    NSString* imgStr = tempSource.url;
    [cell.coverIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    cell.nameLab.text = tempSource.sourceName;
    cell.briefLab.text = @"暂无简介";
    if (tempSource.abstr != nil && tempSource.abstr.length > 0) {
        cell.briefLab.text = tempSource.abstr;
    }
    
    cell.delegate = self;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Source* tempSource = [self.dataArray objectAtIndex:indexPath.row];
    
    LMMediaDetailViewController* mediaDetailVC = [[LMMediaDetailViewController alloc]init];
    mediaDetailVC.mediaId = tempSource.sourceId;
    [self.navigationController pushViewController:mediaDetailVC animated:YES];
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadMySubscriptionDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadMySubscriptionDataWithPage:self.page isLoadMore:YES];
}

#pragma mark -LMMySubscriptionTableViewCellDelegate
-(void)didStartScrollCell:(LMMySubscriptionTableViewCell* )selectedCell {
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMMySubscriptionTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == selectedCell) {
            continue;
        }
        [cell showDelete:NO animation:YES];
    }
}

-(void)didClickCell:(LMMySubscriptionTableViewCell* )cell deleteButton:(UIButton* )btn {
    LoginedRegUser* user = [LMTool getLoginedRegUser];
    if (user == nil) {
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                
            }
        };
        [loginAV startShow];
        
        return;
    }
    
    [self showNetworkLoadingView];
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    Source* tempSource = [self.dataArray objectAtIndex:indexPath.row];
    
    SourceDoReqBuilder* builder = [SourceDoReq builder];
    [builder setSourceId:tempSource.sourceId];
    [builder setType:SourceDoTypeSourceUnfollow];
    SourceDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMMySubscriptionViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    
                    [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }else {//无法增删改
                    [weakSelf showMBProgressHUDWithText:@"删除失败"];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NetworkFailedError];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NetworkFailedError];
    }];
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
