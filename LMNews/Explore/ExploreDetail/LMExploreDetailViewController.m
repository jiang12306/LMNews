//
//  LMExploreDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMExploreDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendImagesTableViewCell.h"
#import "LMRecommendVideoTableViewCell.h"
#import "LMRecommendTextTableViewCell.h"
#import "LMTool.h"
#import "LMExploreDetailModel.h"
#import "LMNewsDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "LMMediaDetailViewController.h"
#import "LMImagesNewsDetailViewController.h"
#import "LMHomeNavigationBarView.h"
#import "LMLoginAlertView.h"

@interface LMExploreDetailViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;

@property (nonatomic, strong) UIButton* subOrderBtn;
@property (nonatomic, strong) UIButton* updateOrderBtn;

@end

@implementation LMExploreDetailViewController

static NSString* imageCellIdentifier = @"imageCellIdentifier";
static NSString* videoCellIdentifier = @"videoCellIdentifier";
static NSString* imagesCellIdentifier = @"imagesCellIdentifier";
static NSString* textCellIdentifier = @"textCellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.currentType = -1;
        self.orderType = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat tabBarHeight = 49;
    CGFloat naviBarHeight = [LMHomeNavigationBarView getHomeNavigationBarViewHeight];
    CGFloat totalNaviHeight = naviBarHeight + 30;
    if ([LMTool isIPhoneX]) {
        tabBarHeight = 83;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight - tabBarHeight - totalNaviHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMRecommendImageTableViewCell class] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerClass:[LMRecommendVideoTableViewCell class] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerClass:[LMRecommendImagesTableViewCell class] forCellReuseIdentifier:imagesCellIdentifier];
    [self.tableView registerClass:[LMRecommendTextTableViewCell class] forCellReuseIdentifier:textCellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    
    UIView* btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 2, self.view.frame.size.width, 40)];
    [headerView addSubview:btnView];
    CGFloat btnWidth = 80;
    self.updateOrderBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - btnWidth, 0, btnWidth, btnView.frame.size.height)];
    self.updateOrderBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.updateOrderBtn setTitle:@"更新排序" forState:UIControlStateNormal];
    [self.updateOrderBtn setTitleColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1] forState:UIControlStateNormal];
    [self.updateOrderBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:self.updateOrderBtn];
    
    UIView* lineVi = [[UIView alloc]initWithFrame:CGRectMake(self.updateOrderBtn.frame.origin.x - 5, 10, 2, 20)];
    lineVi.backgroundColor = [UIColor blackColor];
    [btnView addSubview:lineVi];
    
    self.subOrderBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 20 - btnWidth * 2, 0, btnWidth, btnView.frame.size.height)];
    self.subOrderBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.subOrderBtn setTitle:@"关注排序" forState:UIControlStateNormal];
    [self.subOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    [self.subOrderBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:self.subOrderBtn];
    
    btnView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    self.page = 0;
    self.isEnd = NO;
    self.dataArray = [NSMutableArray array];
    [self loadExploreNewsDataWithPage:self.page isLoadMore:NO];
}

-(void)clickedOrderButton:(UIButton* )sender {
    if (sender == self.subOrderBtn) {
        if (self.orderType == 1) {
            [self.updateOrderBtn setTitleColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1] forState:UIControlStateNormal];
            [self.subOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            self.orderType = 0;
            //刷新
            [self.tableView startRefresh];
        }
    }else if (sender == self.updateOrderBtn) {
        if (self.orderType == 0) {
            [self.subOrderBtn setTitleColor:[UIColor colorWithRed:30/255.f green:30/255.f blue:30/255.f alpha:1] forState:UIControlStateNormal];
            [self.updateOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            self.orderType = 1;
            //刷新
            [self.tableView startRefresh];
        }
    }
}

-(void)loadExploreNewsDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    TansuoReqBuilder* builder = [TansuoReq builder];
    [builder setPage:(UInt32 )page];
    [builder setType:(SInt32 )self.currentType];
    [builder setOrderType:(UInt32 )self.orderType];
    TansuoReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:3 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 3) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TansuoRes* res = [TansuoRes parseFromData:apiRes.body];
                    
                    UInt32 pSize = res.psize;
                    NSArray* arr = res.sourceList;
                    if (arr == nil || arr.count <= pSize) {//最后一页
                        self.isEnd = YES;
                        [self.tableView setupNoMoreData];
                    }
                    
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        NSArray* modelArr = [LMExploreDetailModel convertExploreDetailModelWithDataArray:arr];
                        
                        [self.dataArray addObjectsFromArray:modelArr];
                    }
                    
                    self.page ++;
                    
                    [self.tableView reloadData];
                    
                }
            }
        } @catch (NSException *exception) {
            [self showMBProgressHUDWithText:NetworkFailedError];
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
    }];
}

-(void)pushToMediaDetailVCWithTag:(NSInteger )tag {
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:tag];
    LMSource* source = exploreModel.lmSource;
    LMMediaDetailViewController* mediaDetailVC = [[LMMediaDetailViewController alloc]init];
    mediaDetailVC.mediaId = source.sourceId;
    [self.navigationController pushViewController:mediaDetailVC animated:YES];
}

-(void)clickedSourceAvator:(UITapGestureRecognizer* )tapGR {
    NSInteger tag = tapGR.view.tag;
    [self pushToMediaDetailVCWithTag:tag];
}

-(void)clickedSourceNameButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    [self pushToMediaDetailVCWithTag:tag];
}

-(void)clickedSourceSubscriptionButton:(UIButton* )sender {
    LoginedRegUser* user = [LMTool getLoginedRegUser];
    if (user == nil) {
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        [loginAV startShow];
        
        return;
    }
    
    NSInteger tag = sender.tag;
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:tag];
    LMSource* source = exploreModel.lmSource;
    
    SourceDoType type = SourceDoTypeSourceFollow;
    if (source.isSub) {
        type = SourceDoTypeSourceUnfollow;
    }
    [self showNetworkLoadingView];
    
    SourceDoReqBuilder* builder = [SourceDoReq builder];
    [builder setSourceId:(UInt32 )source.sourceId];
    [builder setType:type];
    SourceDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMExploreDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    if (source.isSub != 0) {
                        source.isSub = 0;
                        [sender setTitle:@"+关注" forState:UIControlStateNormal];
                    }else {
                        source.isSub = 1;
                        [sender setTitle:@"已关注" forState:UIControlStateNormal];
                        sender.backgroundColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
                        sender.enabled = NO;
                    }
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                }else {//无法增删改
                    [weakSelf showMBProgressHUDWithText:@"操作失败"];
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

-(void)clickedMoreButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    [self pushToMediaDetailVCWithTag:tag];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:section];
    LMSource* source = exploreModel.lmSource;
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    vi.backgroundColor = [UIColor whiteColor];
    
    UIImageView* avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    avatorIV.tag = section;
    avatorIV.layer.cornerRadius = 20;
    avatorIV.layer.masksToBounds = YES;
    avatorIV.userInteractionEnabled = YES;
    [avatorIV sd_setImageWithURL:[NSURL URLWithString:source.url] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    [vi addSubview:avatorIV];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedSourceAvator:)];
    [avatorIV addGestureRecognizer:tap];
    
    UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
    tempLab.font = [UIFont systemFontOfSize:18];
    tempLab.text = source.sourceName;
    CGSize labSize = [tempLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];
    
    UIButton* nameBtn = [[UIButton alloc]initWithFrame:CGRectMake(55, 15, labSize.width, 30)];
    nameBtn.tag = section;
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [nameBtn setTitle:source.sourceName forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    [nameBtn addTarget:self action:@selector(clickedSourceNameButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:nameBtn];
    
    UIButton* subBtn = [[UIButton alloc]initWithFrame:CGRectMake(nameBtn.frame.origin.x + nameBtn.frame.size.width + 5, 15, 75, 30)];
    subBtn.backgroundColor = [UIColor colorWithHex:subOrangeString];
    subBtn.layer.cornerRadius = 3;
    subBtn.layer.masksToBounds = YES;
    subBtn.tag = section;
    subBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    if (source.isSub) {
        subBtn.backgroundColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
        subBtn.enabled = NO;
        [subBtn setTitle:@"已关注" forState:UIControlStateNormal];
    }else {
        [subBtn setTitle:@"+关注" forState:UIControlStateNormal];
    }
    [subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [subBtn addTarget:self action:@selector(clickedSourceSubscriptionButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:subBtn];
    
    UILabel* subCountLab = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 90, subBtn.frame.origin.y, 90, 30)];
    subCountLab.textAlignment = NSTextAlignmentRight;
    subCountLab.font = [UIFont systemFontOfSize:13];
    NSInteger tempCount = source.subCount;
    NSString* tempCountStr = [NSString stringWithFormat:@"%ld人已关注", tempCount];
    if (tempCount == 0) {
        tempCountStr = @"";
    }else if (tempCount > 1000) {
        tempCountStr = [NSString stringWithFormat:@"%ld千人已关注", tempCount / 1000];
    }
    subCountLab.text = tempCountStr;
    [vi addSubview:subCountLab];
    
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    
    UIButton* moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, 40)];
    moreBtn.backgroundColor = [UIColor whiteColor];
    moreBtn.tag = section;
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [moreBtn setTitle:@"更多内容>>" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    [moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 15, 0)];
    [moreBtn addTarget:self action:@selector(clickedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:moreBtn];
    
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 42;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:section];
    NSArray* arr = exploreModel.articleList;
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:indexPath.section];
    NSArray* arr = exploreModel.articleList;
    LMRecommendModel* recommendModel = [arr objectAtIndex:indexPath.row];
    return recommendModel.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:section];
    NSArray* tempArr = exploreModel.articleList;
    LMRecommendModel* model = [tempArr objectAtIndex:row];
    LMRecommendModelCellStyle cellStyle = model.cellStyle;
    if (cellStyle == LMRecommendImageTableViewCellStyle) {
        LMRecommendImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
        }
        if (row == tempArr.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendVideoTableViewCellStyle) {
        LMRecommendVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        if (row == tempArr.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendImagesTableViewCellStyle) {
        LMRecommendImagesTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imagesCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImagesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imagesCellIdentifier];
        }
        if (row == tempArr.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendTextTableViewCellStyle) {
        LMRecommendTextTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendTextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
        }
        if (row == tempArr.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    LMExploreDetailModel* exploreModel = [self.dataArray objectAtIndex:section];
    NSArray* arr = exploreModel.articleList;
    LMRecommendModel* recommendModel = [arr objectAtIndex:row];
    recommendModel.alreadyRead = YES;
    LMArticleSimple* simple = recommendModel.article;
    
    if (simple.isAllPic) {
        LMImagesNewsDetailViewController* imagesDetailVC = [[LMImagesNewsDetailViewController alloc]init];
        imagesDetailVC.newsId = simple.articleId;
        [self.navigationController pushViewController:imagesDetailVC animated:YES];
    }else {
        LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
        newsDetailVC.newsId = simple.articleId;
        [self.navigationController pushViewController:newsDetailVC animated:YES];
    }
    [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:simple.articleId isRead:YES];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
    self.page = 0;
    self.isEnd = NO;
    
    [self loadExploreNewsDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        [self.tableView stopRefresh];
        return;
    }
    
    [self loadExploreNewsDataWithPage:self.page isLoadMore:YES];
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
