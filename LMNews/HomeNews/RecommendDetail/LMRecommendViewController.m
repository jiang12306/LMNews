//
//  LMRecommendViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendVideoTableViewCell.h"
#import "LMRecommendImagesTableViewCell.h"
#import "LMRecommendTextTableViewCell.h"
#import "LMRecommendCollectionTableViewCell.h"
#import "LMRecommendListTableViewCell.h"
#import "LMTool.h"
#import "LMRecommendModel.h"
#import "LMNewsDetailViewController.h"
#import "LMZhuanTiDetailViewController.h"

@interface LMRecommendViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation LMRecommendViewController

static NSString* imageCellIdentifier = @"imageCellIdentifier";
static NSString* videoCellIdentifier = @"videoCellIdentifier";
static NSString* imagesCellIdentifier = @"imagesCellIdentifier";
static NSString* textCellIdentifier = @"textCellIdentifier";
static NSString* collectionCellIdentifier = @"collectionCellIdentifier";
static NSString* listCellIdentifier = @"listCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat tabBarHeight = 49;
    CGFloat naviBarHeight = 64 + 40;
    if ([LMTool isIPhoneX]) {
        tabBarHeight = 83;
        naviBarHeight = 88 + 40;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight - tabBarHeight - naviBarHeight) style:UITableViewStyleGrouped];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMRecommendImageTableViewCell class] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerClass:[LMRecommendVideoTableViewCell class] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerClass:[LMRecommendImagesTableViewCell class] forCellReuseIdentifier:imagesCellIdentifier];
    [self.tableView registerClass:[LMRecommendTextTableViewCell class] forCellReuseIdentifier:textCellIdentifier];
    [self.tableView registerClass:[LMRecommendCollectionTableViewCell class] forCellReuseIdentifier:collectionCellIdentifier];
    [self.tableView registerClass:[LMRecommendListTableViewCell class] forCellReuseIdentifier:listCellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    
    self.page = 0;
    self.isEnd = NO;
    self.dataArray = [NSMutableArray array];
    [self loadRecommendNewsDataWithPage:self.page isLoadMore:NO];
}

/**
 *  @param page : 页数
 *  @param isLoadMore : 是否上拉
 */
-(void)loadRecommendNewsDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    QiwenListReqBuilder* builder = [QiwenListReq builder];
    [builder setPage:(UInt32 )page];
    [builder setType:self.homeType];
    QiwenListReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:2 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 2) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    QiwenListRes* res = [QiwenListRes parseFromData:apiRes.body];
                    
                    NSArray* arr = res.articleList;
                    NSInteger pSize = res.psize;
                    if (arr == nil || arr.count < pSize) {
                        self.isEnd = YES;
                    }else {
                        self.isEnd = NO;
                    }
                    BOOL shouldReload = YES;
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        
                        NSArray* modelArr = [LMRecommendModel convertModelWithArray:arr];
                        if (self.homeType == ListTypeTHot) {
                            for (LMRecommendModel* model in modelArr) {
                                if (model.time != nil && model.time.length > 0) {
                                    model.showTime = YES;
                                    model.cellHeight += 30;
                                }
                            }
                        }
                        if (self.homeType == ListTypeTRecommend) {
                            if (!isLoadMore) {
                                if (self.dataArray.count == 0) {
                                    [self.dataArray addObjectsFromArray:modelArr];
                                }else {
                                    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, modelArr.count)];
                                    [self.dataArray insertObjects:modelArr atIndexes:indexSet];
                                    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
                                    
                                    shouldReload = NO;
                                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:modelArr.count];
                                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                }
                            }else {
                                [self.dataArray addObjectsFromArray:modelArr];
                            }
                        }else {
                            [self.dataArray addObjectsFromArray:modelArr];
                        }
                    }
                    if (self.page == 0 && self.dataArray.count == 0) {
                        [self showEmptyLabelWithText:nil];
                    }else {
                        [self hideEmptyLabel];
                    }
                    [self hideReloadButton];
                    
                    self.page ++;
                    
                    if (shouldReload){
                        [self.tableView reloadData];
                    }
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
            
            if (self.homeType == ListTypeTRecommend) {
                [self saveLastLoadDataTime];
            }
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
        
        if (self.homeType == ListTypeTRecommend) {
            [self saveLastLoadDataTime];
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
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    LMRecommendModelCellStyle cellStyle = model.cellStyle;
    if (cellStyle == LMRecommendImageTableViewCellStyle) {
        LMRecommendImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendVideoTableViewCellStyle) {
        LMRecommendVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendImagesTableViewCellStyle) {
        LMRecommendImagesTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imagesCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImagesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imagesCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendTextTableViewCellStyle) {
        LMRecommendTextTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendTextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendCollectionTableViewCellStyle) {
        LMRecommendCollectionTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:collectionCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendCollectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collectionCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        __weak LMRecommendViewController* weakSelf = self;
        cell.itemBlock = ^(NSInteger index) {
            LMZhuanTi* zhuanTi = model.zt;
            NSArray* tempArticleArr = zhuanTi.list;
            @try {
                LMArticleSimple* tempSimp = [tempArticleArr objectAtIndex:index];
                LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
                newsDetailVC.newsId = tempSimp.articleId;
                [weakSelf.navigationController pushViewController:newsDetailVC animated:YES];
                
                [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:tempSimp.articleId isRead:YES];
                
                model.alreadyRead = YES;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        };
        
        return cell;
    }else if (cellStyle == LMRecommendListTableViewCellStyle) {
        LMRecommendListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:listCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        __weak LMRecommendViewController* weakSelf = self;
        cell.cellBlock = ^(NSInteger index) {
            LMZhuanTi* zhuanTi = model.zt;
            NSArray* tempArticleArr = zhuanTi.list;
            @try {
                LMArticleSimple* tempSimp = [tempArticleArr objectAtIndex:index];
                LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
                newsDetailVC.newsId = tempSimp.articleId;
                [weakSelf.navigationController pushViewController:newsDetailVC animated:YES];
                
                [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:tempSimp.articleId isRead:YES];
                
                model.alreadyRead = YES;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        };
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    
    if (model.articleType == 1) {//文章
        LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
        LMArticleSimple* articleSimple = model.article;
        newsDetailVC.newsId = articleSimple.articleId;
        [self.navigationController pushViewController:newsDetailVC animated:YES];
        
        [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:articleSimple.articleId isRead:YES];
        
        model.alreadyRead = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else if (model.articleType == 2) {//专题
        LMZhuanTiDetailViewController* zhuanTiDetailVC = [[LMZhuanTiDetailViewController alloc]init];
        zhuanTiDetailVC.zhuanTi = model.zt;
        [self.navigationController pushViewController:zhuanTiDetailVC animated:YES];
        
        [[LMDatabaseTool sharedDatabaseTool] setZhuanTiWithZhuanTiId:model.zt.zhuanTiId isRead:YES];
        
        model.alreadyRead = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.homeType == ListTypeTRecommend) {
        if (self.isEnd) {
            self.page = 0;
        }else {
            if ([self shouldReset]) {
                self.page = 0;
            }
        }
    }else {
        self.page = 0;
        self.isEnd = NO;
    }
    
    [self loadRecommendNewsDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.homeType == ListTypeTRecommend) {
        if (self.isEnd) {
            self.page = 0;
        }
    }else {
        if (self.isEnd) {
            [self.tableView stopLoadMoreData];
            return;
        }
    }
    
    [self loadRecommendNewsDataWithPage:self.page isLoadMore:YES];
}

-(void)saveLastLoadDataTime {
    NSDate *datenow = [NSDate date];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:datenow forKey:@"recommendLoadDate"];
    [userDefaults synchronize];
}

-(BOOL )shouldReset {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate* lastDate = [userDefaults objectForKey:@"recommendLoadDate"];
    NSDate* date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSinceDate:lastDate];
    if (time > 60 * 10 || time < -60 * 10) {
        return YES;
    }
    return NO;
}

-(void)startRefreshRecommendData {
    [self.tableView startRefresh];
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
