//
//  LMMySystemMessageViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/25.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMySystemMessageViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMMySystemMessageTableViewCell.h"
#import "LMMyFollowMessageTableViewCell.h"
#import "LMMyMessageModel.h"
#import "LMMySystemMessageDetailViewController.h"
#import "LMHomeRightBarButtonItemView.h"
#import "LMTool.h"

@interface LMMySystemMessageViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation LMMySystemMessageViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    
    CGFloat naviBarHeight = 64;
    if ([LMTool isIPhoneX]) {
        naviBarHeight = 88;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, self.topY, self.view.frame.size.width, self.view.frame.size.height - self.topY - naviBarHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMMySystemMessageTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    self.page = 0;
    self.isEnd = NO;
    self.dataArray = [NSMutableArray array];
    [self loadMySystemMessageDataWithPage:self.page isLoadMore:NO];
}

-(void)loadMySystemMessageDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    SysMsgListReqBuilder* builder = [SysMsgListReq builder];
    [builder setPage:(UInt32 )page];
    SysMsgListReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:21 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 21) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SysMsgListRes* res = [SysMsgListRes parseFromData:apiRes.body];
                    
                    UInt32 pSize = res.psize;
                    NSArray* arr = res.sysmsgs;
                    if (arr == nil || arr.count <= pSize) {//最后一页
                        self.isEnd = YES;
                        [self.tableView setupNoMoreData];
                    }
                    
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        
                        for (SysMsg* msg in arr) {
                            LMMySystemMessageModel* systemModel = [[LMMySystemMessageModel alloc]init];
                            systemModel.msgId = msg.id;
                            systemModel.title = msg.title;
                            systemModel.content = msg.content;
                            systemModel.isRead = msg.isRead;
                            systemModel.time = msg.sT;
                            UIFont* font = [UIFont boldSystemFontOfSize:16];
                            if (systemModel.isRead) {
                                font = [UIFont systemFontOfSize:16];
                            }
                            systemModel.titleHeight = [self caculateSystemMessageHeightWithFont:font text:systemModel.title];
                            
                            [self.dataArray addObject:systemModel];
                        }
                    }
                    if (self.page == 0 && self.dataArray.count == 0) {
                        [self showEmptyLabelWithText:nil];
                    }else {
                        [self hideEmptyLabel];
                    }
                    [self hideReloadButton];
                    
                    self.page ++;
                    NSArray* tempArr = [self rangeArrayWithArray:self.dataArray];
                    if (tempArr != nil && tempArr.count > 0) {
                        [self.dataArray removeAllObjects];
                        [self.dataArray addObjectsFromArray:tempArr];
                    }
                    
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

-(CGFloat )caculateSystemMessageHeightWithFont:(UIFont* )font text:(NSString* )text {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectZero];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    lab.font = font;
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(self.view.frame.size.width - 10 * 2, CGFLOAT_MAX)];
    return labSize.height;
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
    NSInteger row = indexPath.row;
    
    LMMySystemMessageModel* model = [self.dataArray objectAtIndex:row];
    
    CGFloat cellHeight = 30 + 15;
    
    cellHeight += model.titleHeight;
    
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    LMMySystemMessageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMMySystemMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    LMMySystemMessageModel* model = [self.dataArray objectAtIndex:row];
    [cell setupMessageContentWithModel:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMMySystemMessageModel* model = [self.dataArray objectAtIndex:indexPath.row];
    model.isRead = 1;
    model.titleHeight = [self caculateSystemMessageHeightWithFont:[UIFont systemFontOfSize:16] text:model.title];
    
    NSArray* tempArr = [self rangeArrayWithArray:self.dataArray];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:tempArr];
    [self.tableView reloadData];
    
    LMMySystemMessageDetailViewController* detailVC = [[LMMySystemMessageDetailViewController alloc]init];
    detailVC.msgId = model.msgId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
    self.page = 0;
    self.isEnd = NO;
    
    [self loadMySystemMessageDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        [self.tableView stopRefresh];
        return;
    }

    [self loadMySystemMessageDataWithPage:self.page isLoadMore:YES];
}

//
-(NSArray* )rangeArrayWithArray:(NSArray* )orginalArr {
    NSMutableArray* resultArr = [NSMutableArray array];
    NSMutableArray* readArr = [NSMutableArray array];
    NSMutableArray* unreadArr = [NSMutableArray array];
    
    for (LMMySystemMessageModel* model in orginalArr) {
        if (model.isRead) {
            [readArr addObject:model];
        }else {
            [unreadArr addObject:model];
        }
    }
    if (unreadArr.count > 0) {
        [resultArr addObjectsFromArray:unreadArr];
        
        //
        [LMHomeRightBarButtonItemView setupNewMessage:YES];
    }else {
        [LMHomeRightBarButtonItemView setupNewMessage:NO];
    }
    
    if (readArr.count > 0) {
        [resultArr addObjectsFromArray:readArr];
    }
    
    return resultArr;
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
