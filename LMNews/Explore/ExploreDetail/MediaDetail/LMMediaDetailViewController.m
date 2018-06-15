//
//  LMMediaDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMediaDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendVideoTableViewCell.h"
#import "LMRecommendImagesTableViewCell.h"
#import "LMRecommendTextTableViewCell.h"
#import "LMRecommendModel.h"
#import "LMNewsDetailViewController.h"
#import "LMMediaDetailCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMFastLoginViewController.h"
#import "LMTool.h"

@interface LMMediaDetailViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* avatorIV;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* briefLab;
@property (nonatomic, strong) UIButton* subBtn;
@property (nonatomic, strong) UILabel* subCountLab;
@property (nonatomic, assign) NSInteger subCount;
@property (nonatomic, strong) UILabel* alikeLab;/**<相似媒体推荐*/
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* mediaArray;
@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isAlreadySub;

@end

@implementation LMMediaDetailViewController

static NSString* imageCellIdentifier = @"imageCellIdentifier";
static NSString* videoCellIdentifier = @"videoCellIdentifier";
static NSString* imagesCellIdentifier = @"imagesCellIdentifier";
static NSString* textCellIdentifier = @"textCellIdentifier";

static NSString* mediaCellIdentifier = @"mediaCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"媒体详情";
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMRecommendImageTableViewCell class] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerClass:[LMRecommendVideoTableViewCell class] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerClass:[LMRecommendImagesTableViewCell class] forCellReuseIdentifier:imagesCellIdentifier];
    [self.tableView registerClass:[LMRecommendTextTableViewCell class] forCellReuseIdentifier:textCellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    
    self.mediaArray = [NSMutableArray array];
    self.page = 0;
    self.dataArray = [NSMutableArray array];
    [self loadMediaDetailDataWithPage:self.page isLoadMore:NO];
    
}

-(void)setupHeaderViewWithSource:(Source* )source {
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        self.headerView.backgroundColor = [UIColor whiteColor];
        
        self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
        [self.avatorIV sd_setImageWithURL:[NSURL URLWithString:source.url] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
        [self.headerView addSubview:self.avatorIV];
        
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + 10, self.avatorIV.frame.origin.y, self.view.frame.size.width - self.avatorIV.frame.origin.x - self.avatorIV.frame.size.width - 10 * 2, 30)];
        self.nameLab.font = [UIFont systemFontOfSize:20];
        self.nameLab.text = source.sourceName;
        self.nameLab.textColor = [UIColor colorWithHex:themeOrangeString];
        [self.headerView addSubview:self.nameLab];
        
        if (source.abstr != nil && source.abstr.length > 0) {
            self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, 20)];
            self.briefLab.font = [UIFont systemFontOfSize:16];
            self.briefLab.numberOfLines = 2;
            self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
            self.briefLab.text = source.abstr;
            [self.headerView addSubview:self.briefLab];
            
            CGSize labSize = [self.briefLab sizeThatFits:CGSizeMake(self.nameLab.frame.size.width, CGFLOAT_MAX)];
            if (labSize.height / self.briefLab.font.lineHeight > 2) {
                self.briefLab.frame = CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, self.briefLab.font.lineHeight * 2);
            }
        }else {
            self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, 0)];
            [self.headerView addSubview:self.briefLab];
        }
        
        self.subBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, 80, 20)];
        self.subBtn.backgroundColor = [UIColor colorWithHex:subOrangeString];
        self.subBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        if (source.isSub) {
            self.isAlreadySub = YES;
            [self.subBtn setTitle:@"取消关注" forState:UIControlStateNormal];
        }else {
            self.isAlreadySub = NO;
            [self.subBtn setTitle:@"+关注" forState:UIControlStateNormal];
        }
        [self.subBtn addTarget:self action:@selector(clickedSourceSubscriptionButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.subBtn];
        
        self.subCountLab = [[UILabel alloc]initWithFrame:CGRectMake(self.subBtn.frame.origin.x + self.subBtn.frame.size.width + 10, self.subBtn.frame.origin.y, self.view.frame.size.width - self.subBtn.frame.origin.x - self.subBtn.frame.size.width - 10 * 2, self.subBtn.frame.size.height)];
        self.subCountLab.font = [UIFont systemFontOfSize:16];
        self.subCountLab.textColor = [UIColor colorWithHex:alreadyReadString];
        [self.headerView addSubview:self.subCountLab];
        self.subCount = source.subCount;
        
        CGFloat tempHeight = self.subBtn.frame.origin.y + self.subBtn.frame.size.height;
        if (tempHeight < self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height) {
            tempHeight = self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height;
        }
        
        if (self.mediaArray != nil && self.mediaArray.count > 0) {
            UIView* lineVi = [[UIView alloc]initWithFrame:CGRectMake(0, tempHeight + 10, self.headerView.frame.size.width, 5)];
            lineVi.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
            [self.headerView addSubview:lineVi];
            
            self.alikeLab = [[UILabel alloc]initWithFrame:CGRectMake(10, tempHeight + 20, self.view.frame.size.width - 20, 30)];
            self.alikeLab.font = [UIFont boldSystemFontOfSize:18];
            self.alikeLab.text = @"相似媒体推荐";
            [self.headerView addSubview:self.alikeLab];
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.alikeLab.frame.origin.y + self.alikeLab.frame.size.height + 10, self.view.frame.size.width, 100) collectionViewLayout:layout];
            self.collectionView.showsHorizontalScrollIndicator = NO;
            self.collectionView.alwaysBounceHorizontal = YES;
            self.collectionView.alwaysBounceVertical = NO;
            self.collectionView.backgroundColor = [UIColor whiteColor];
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
            [self.collectionView registerClass:[LMMediaDetailCollectionViewCell class] forCellWithReuseIdentifier:mediaCellIdentifier];
            [self.headerView addSubview:self.collectionView];
            
            self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + 10);
        }else {
            self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, tempHeight + 10);
        }
        
        self.tableView.tableHeaderView = self.headerView;
    }
}

-(void)setSubCount:(NSInteger)subCount {
    NSString* tempSubCountStr = [NSString stringWithFormat:@"(%ld人已关注)", subCount];
    if (subCount > 1000) {
        tempSubCountStr = [NSString stringWithFormat:@"(%ld千人已关注)", subCount / 1000];
    }
    self.subCountLab.text = tempSubCountStr;
    _subCount = subCount;
}

-(void)clickedSourceSubscriptionButton:(UIButton* )sender {
    SourceDoType type = SourceDoTypeSourceFollow;
    if (self.isAlreadySub) {
        type = SourceDoTypeSourceUnfollow;
    }
    [self showNetworkLoadingView];
    
    SourceDoReqBuilder* builder = [SourceDoReq builder];
    [builder setSourceId:(UInt32 )self.mediaId];
    [builder setType:type];
    SourceDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMMediaDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        LoginedRegUser* user = [LMTool getLoginedRegUser];
        if (user == nil) {
            LMFastLoginViewController* fastLoginVC = [[LMFastLoginViewController alloc]init];
            fastLoginVC.userBlock = ^(LoginedRegUser *loginUser) {
                if (loginUser != nil) {
                    //
                }
            };
            [weakSelf.navigationController pushViewController:fastLoginVC animated:YES];
            
            return;
        }
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    self.isAlreadySub = !self.isAlreadySub;
                    if (self.isAlreadySub) {
                        [self.subBtn setTitle:@"取消关注" forState:UIControlStateNormal];
                    }else {
                        [self.subBtn setTitle:@"+关注" forState:UIControlStateNormal];
                    }
                    [self showMBProgressHUDWithText:@"操作成功"];
                }else {//无法增删改
                    [self showMBProgressHUDWithText:@"操作失败"];
                }
            }
        } @catch (NSException *exception) {
            [self showMBProgressHUDWithText:NetworkFailedError];
        } @finally {
            [self hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
        [self showMBProgressHUDWithText:NetworkFailedError];
    }];
}

-(void)loadMediaDetailDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    SourceReqBuilder* builder = [SourceReq builder];
    [builder setPage:(UInt32 )page];
    [builder setId:(UInt32 )self.mediaId];
    SourceReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 4) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SourceRes* res = [SourceRes parseFromData:apiRes.body];
                    
                    NSArray* arr1 = res.sourceLike;
                    for (Source* source in arr1) {
                        LMSource* lmSource = [LMSource convertLMSourceWithSource:source];
                        [self.mediaArray addObject:lmSource];
                    }
                    
                    Source* source = res.source;
                    [self setupHeaderViewWithSource:source];
                    
                    
                    NSArray* arr = res.articleList;
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        for (ArticleSimple* simple in arr) {
                            LMRecommendModel* model = [LMRecommendModel convertExploreDataToModelWithArticleSimple:simple];
                            [self.dataArray addObject:model];
                        }
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


#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMMediaDetailCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:mediaCellIdentifier forIndexPath:indexPath];
    
    LMSource* source = [self.mediaArray objectAtIndex:indexPath.row];
    cell.nameLab.text = source.sourceName;
    [cell setupSubscriptionWithSource:source];
    
    __weak LMMediaDetailViewController* weakSelf = self;
    
    cell.block = ^(BOOL click, LMMediaDetailCollectionViewCell *clickCell) {
        SourceDoType type = SourceDoTypeSourceFollow;
        if (source.isSub) {
            type = SourceDoTypeSourceUnfollow;
        }
        [weakSelf showNetworkLoadingView];
        
        SourceDoReqBuilder* builder = [SourceDoReq builder];
        [builder setSourceId:(UInt32 )source.sourceId];
        [builder setType:type];
        SourceDoReq* req = [builder build];
        NSData* reqData = [req data];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
            LoginedRegUser* user = [LMTool getLoginedRegUser];
            if (user == nil) {
                LMFastLoginViewController* fastLoginVC = [[LMFastLoginViewController alloc]init];
                fastLoginVC.userBlock = ^(LoginedRegUser *loginUser) {
                    if (loginUser != nil) {
                        //
                    }
                };
                [weakSelf.navigationController pushViewController:fastLoginVC animated:YES];
                
                return;
            }
            @try {
                QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                if (apiRes.cmd == 8) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {//成功
                        if (source.isSub != 0) {
                            source.isSub = 0;
                        }else {
                            source.isSub = 1;
                        }
                        [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        
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
    };
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LMSource* source = [self.mediaArray objectAtIndex:indexPath.row];
    
    LMMediaDetailViewController* mediaDetailVC = [[LMMediaDetailViewController alloc]init];
    mediaDetailVC.mediaId = source.sourceId;
    [self.navigationController pushViewController:mediaDetailVC animated:YES];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}



#pragma mark -UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
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
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    LMArticleSimple* articleSimple = model.article;
    newsDetailVC.newsId = articleSimple.articleId;
    [self.navigationController pushViewController:newsDetailVC animated:YES];
    
    [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:articleSimple.articleId isRead:YES];
    
    model.alreadyRead = YES;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
    self.page = 0;
    [self loadMediaDetailDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self loadMediaDetailDataWithPage:self.page isLoadMore:YES];
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
