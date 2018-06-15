//
//  LMCommentDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMCommentDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMCommentTableViewCell.h"
#import "LMRecommendModel.h"
#import "LMCommentView.h"
#import "LMCommentInputView.h"
#import "LMTool.h"
#import "LMFastLoginViewController.h"
#import "LMShareView.h"
#import "LMShareMessage.h"

@interface LMCommentDetailViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate, LMCommentTableViewCellDelegate>

@property (nonatomic, strong) LMCommentView* commentView;

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, assign) NSInteger orderType;

@property (nonatomic, strong) UIButton* timeOrderBtn;/**<最新排序*/
@property (nonatomic, strong) UIButton* hotOrderBtn;/**<最热排序*/

@end

@implementation LMCommentDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"精彩评论";
    
    CGFloat naviBarHeight = 64;
    CGFloat footerHeight = 44;
    if ([LMTool isIPhoneX]) {
        naviBarHeight = 88;
        footerHeight += 20;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviBarHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMCommentTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    CGFloat btnWidth = 80;
    CGFloat btnHeight = 40;
    self.timeOrderBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - btnWidth - 10, 10, btnWidth, btnHeight)];
    self.timeOrderBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.timeOrderBtn setTitle:@"最新排序" forState:UIControlStateNormal];
    [self.timeOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    [self.timeOrderBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.timeOrderBtn];
    
    UIView* lineVi = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 3, 20)];
    lineVi.backgroundColor = [UIColor blackColor];
    [headerView addSubview:lineVi];
    lineVi.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2);
    
    self.hotOrderBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 10, 10, btnWidth, btnHeight)];
    self.hotOrderBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.hotOrderBtn setTitle:@"最热排序" forState:UIControlStateNormal];
    [self.hotOrderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hotOrderBtn addTarget:self action:@selector(clickedOrderButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.hotOrderBtn];
    
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    
    self.orderType = 0;
    self.page = 0;
    self.isEnd = NO;
    self.dataArray = [NSMutableArray array];
    [self loadCommentDetailDataWithPage:self.page isLoadMore:NO];
    
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shareNewsSucceed:) name:weChatShareNotifyName object:nil];
}

-(void)shareNewsSucceed:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        [self showMBProgressHUDWithText:@"分享失败"];
        return;
    }
    [self showMBProgressHUDWithText:@"分享成功"];
}

-(void)clickedOrderButton:(UIButton* )sender {
    if (sender == self.timeOrderBtn) {
        if (self.orderType == 1) {
            [self.hotOrderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.timeOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            self.orderType = 0;
            //刷新
            [self.tableView startRefresh];
        }
    }else if (sender == self.hotOrderBtn) {
        if (self.orderType == 0) {
            [self.hotOrderBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
            [self.timeOrderBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.orderType = 1;
            //刷新
            [self.tableView startRefresh];
        }
    }
}

-(void)setupToolBar {
    __weak LMCommentDetailViewController* weakSelf = self;
    
    self.commentView = [[LMCommentView alloc]init];
    [self.commentView setupCommentCount:self.commentCount];
    self.commentView.commentBlock = ^(BOOL didStart) {
        if (didStart) {
            LoginedRegUser* user = [LMTool getLoginedRegUser];
            if (user == nil) {
                LMFastLoginViewController* fastLoginVC = [[LMFastLoginViewController alloc]init];
                fastLoginVC.userBlock = ^(LoginedRegUser *loginUser) {
                    if (loginUser != nil) {
                        [weakSelf showCommentInputView];
                    }
                };
                [weakSelf.navigationController pushViewController:fastLoginVC animated:YES];
                
                return;
            }
            
            [weakSelf showCommentInputView];
        }
    };
    self.commentView.collectBlock = ^(BOOL didStart) {
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
        
        [weakSelf showNetworkLoadingView];
        
        BookmarkDoReqBuilder* builder = [BookmarkDoReq builder];
        [builder setArticleId:(UInt32 )weakSelf.articleId];
        BookmarkDoType markType = BookmarkDoTypeArticleBookmark;
        if (weakSelf.isMark) {
            markType = BookmarkDoTypeArticleUnbookmark;
        }
        [builder setType:markType];
        BookmarkDoReq* req = [builder build];
        NSData* reqData = [req data];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:9 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                if (apiRes.cmd == 9) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {//成功
                        weakSelf.isMark = !weakSelf.isMark;
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
    self.commentView.shareBlock = ^(BOOL didStart) {
        if (didStart) {
            LMShareView* shareView = [[LMShareView alloc]init];
            shareView.shareBlock = ^(LMShareViewType shareType) {
                if (weakSelf.articleUrl != nil && weakSelf.articleUrl.length > 0) {
                    
                    UIImage* tempImg = [UIImage imageNamed:@"share_Link"];
                    if (weakSelf.articleImg != nil) {
                        tempImg = weakSelf.articleImg;
                    }
                    if (shareType == LMShareViewTypeWeChat || shareType == LMShareViewTypeWeChatMoment) {
                        NSData* imgData = UIImageJPEGRepresentation(tempImg, 0.5);
                        tempImg = [UIImage imageWithData:imgData];
                        if (imgData.length / 1024 > 32) {//图片大于32KB，给默认图
                            tempImg = [UIImage imageNamed:@"share_Link"];
                        }
                    }
                    if (shareType == LMShareViewTypeWeChat) {
                        [LMShareMessage shareToWeChatWithTitle:weakSelf.articleTitle description:weakSelf.articleBrief urlStr:weakSelf.articleUrl isMoment:NO img:tempImg];
                    }else if (shareType == LMShareViewTypeWeChatMoment) {
                        [LMShareMessage shareToWeChatWithTitle:weakSelf.articleTitle description:weakSelf.articleBrief urlStr:weakSelf.articleUrl isMoment:YES img:tempImg];
                    }else if (shareType == LMShareViewTypeQQ) {
                        [LMShareMessage shareToQQWithTitle:weakSelf.articleTitle description:weakSelf.articleBrief urlStr:weakSelf.articleUrl isZone:NO imgStr:weakSelf.articleImgUrl];
                    }else if (shareType == LMShareViewTypeQQZone) {
                        [LMShareMessage shareToQQWithTitle:weakSelf.articleTitle description:weakSelf.articleBrief urlStr:weakSelf.articleUrl isZone:YES imgStr:weakSelf.articleImgUrl];
                    }else if (shareType == LMShareViewTypeCopyLink) {
                        [[UIPasteboard generalPasteboard]setString:weakSelf.articleUrl];
                        
                        [weakSelf showMBProgressHUDWithText:@"复制成功"];
                    }
                }
            };
            [shareView startShow];
        }
    };
    [self.view insertSubview:self.commentView aboveSubview:self.tableView];
    self.commentView.center = CGPointMake(self.view.frame.size.width / 2, self.tableView.frame.origin.y + self.tableView.frame.size.height - self.commentView.frame.size.height / 2);
}

-(void)showCommentInputView {
    LMCommentInputView* inputView = [[LMCommentInputView alloc]init];
    [inputView startShow];
    inputView.inputText = ^(NSString* inputStr) {
        if (inputStr != nil && inputStr.length > 0) {
            CommentBuilder* builder = [Comment builder];
            [builder setArticleId:(UInt32 )self.articleId];
            [builder setText:inputStr];
            Comment* customComment = [builder build];
            
            PubCommentReqBuilder* reqBuilder = [PubCommentReq builder];
            [reqBuilder setComment:customComment];
            PubCommentReq* req = [reqBuilder build];
            NSData* reqData = [req data];
            
            [self showNetworkLoadingView];
            LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
            [networkTool postWithCmd:5 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                    if (apiRes.cmd == 5) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            [self showMBProgressHUDWithText:@"评论成功"];
                            
                            [self.tableView startRefresh];
                        }
                    }
                } @catch (NSException *exception) {
                    [self showMBProgressHUDWithText:NetworkFailedError];
                } @finally {
                    [self hideNetworkLoadingView];
                }
            } failureBlock:^(NSError *failureError) {
                [self showMBProgressHUDWithText:NetworkFailedError];
                [self hideNetworkLoadingView];
            }];
        }
    };
}

-(void)loadCommentDetailDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    ArticleCommentsReqBuilder* builder = [ArticleCommentsReq builder];
    [builder setPage:(UInt32 )page];
    [builder setSort:(UInt32 )self.orderType];
    [builder setArticleId:(UInt32 )self.articleId];
    ArticleCommentsReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:6 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 6) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    ArticleCommentsRes* res = [ArticleCommentsRes parseFromData:apiRes.body];
                    
                    UInt32 pSize = res.psize;
                    NSArray* arr = res.commentList;
                    if (arr == nil || arr.count <= pSize) {//最后一页
                        [self.tableView setupNoMoreData];
                        self.isEnd = YES;
                    }
                    
                    [self setupToolBar];
                    
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        for (Comment* tempCom in arr) {
                            LMCommentModel* model = [[LMCommentModel alloc]init];
                            model.commentId = tempCom.id;
                            if (tempCom.prevUser != nil) {
                                NSString* nickStr = tempCom.prevUser.phoneNum;
                                if (tempCom.prevUser.nickname != nil && tempCom.prevUser.nickname.length > 0) {
                                    nickStr = tempCom.prevUser.nickname;
                                }
                                model.text = [NSString stringWithFormat:@"@%@ 评论 %@", nickStr, tempCom.text];
                            }else {
                                model.text = tempCom.text;
                            }
                            model.articleId = tempCom.articleId;
                            
                            model.prevId = tempCom.prevId;
                            model.prevUid = tempCom.prevUid;
                            model.upCount = tempCom.upCount;
                            
                            RegUser* user = tempCom.user;
                            model.user = user;
                            if (user.phoneNum != nil && user.phoneNum.length > 0) {
                                model.nameWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:user.phoneNum maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:CommentNameFontSize]];
                            }
                            model.prevUser = tempCom.prevUser;
                            model.upCount = tempCom.upCount;
                            if (tempCom.hasUpCount) {
                                NSString* likeStr = [NSString stringWithFormat:@"%ld", (long)model.upCount];
                                model.likeWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:likeStr maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:16]];
                            }else {
                                model.likeWidth = 0;
                            }
                            model.downCount = tempCom.downCount;
                            if (tempCom.hasDownCount) {
                                NSString* unlikeStr = [NSString stringWithFormat:@"%ld", (long)model.downCount];
                                model.unlikeWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:unlikeStr maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:16]];
                            }else {
                                model.unlikeWidth = 0;
                            }
                            NSString* tempTimeStr = tempCom.cT;
                            if (tempTimeStr != nil && tempTimeStr.length >= 10) {
                                tempTimeStr = [tempTimeStr substringToIndex:10];
                            }
                            tempTimeStr = [NSString stringWithFormat:@"(%@)", tempTimeStr];
                            model.time = tempTimeStr;
                            model.timeWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:tempTimeStr maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:CommentNameFontSize]];
                            model.isFold = NO;
                            if (model.text != nil && model.text.length > 0) {
                                [LMCommentModel caculateCommentLabelHeightWithText:model.text maxWidth:(self.view.frame.size.width - CommentAvatorIVWidth - 10 * 3) maxLines:0 font:[UIFont systemFontOfSize:CommentContentFontSize] block:^(CGFloat labHeight, CGFloat labOriginHeight, NSInteger lines) {
                                    
                                    model.contentHeight = labHeight;
                                    model.contentOriginHeight = labOriginHeight;
                                }];
                            }
                            model.isUp = NO;
                            if (tempCom.isUp) {
                                model.isUp = YES;
                            }
                            model.isDown = NO;
                            if (tempCom.isDown) {
                                model.isDown = YES;
                            }
                            
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
    LMCommentModel* model = [self.dataArray objectAtIndex:row];
    
    CGFloat cellHeight = 30;
    if (model.isFold) {
        if (model.contentHeight > 0) {
            cellHeight += (10 * 3 + model.contentOriginHeight);
        }
    }else {
        if (model.contentOriginHeight > 0) {
            cellHeight += (10 * 3 + model.contentOriginHeight);
        }
    }
    
    return cellHeight > CommentAvatorIVWidth ? cellHeight : CommentAvatorIVWidth;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    LMCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.delegate = self;
    
    RegUser* user = [LMTool getLoginedRegUser].user;
    LMCommentModel* model = [self.dataArray objectAtIndex:row];
    
    [cell setupContentWithModel:model];
    
    [cell canSpan:NO];
    if ([model.user.uid isEqualToString:user.uid]) {
        [cell canSpan:YES];
    }
    
    __weak LMCommentDetailViewController* weakSelf = self;
    
    cell.likeBlock = ^(BOOL isLike, LMCommentTableViewCell *likeCell) {
        if (isLike) {
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
            [weakSelf operationCommentWithType:CommentDoTypeCommentUp commentId:(UInt32 )model.commentId];
        }
    };
    
    cell.unlikeBlock = ^(BOOL isUnlike, LMCommentTableViewCell *unlikeCell) {
        if (isUnlike) {
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
            [weakSelf operationCommentWithType:CommentDoTypeCommentDown commentId:(UInt32 )model.commentId];
        }
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    LMCommentModel* model = [self.dataArray objectAtIndex:row];
    
    LoginedRegUser* user = [LMTool getLoginedRegUser];
    if ([user.user.uid isEqualToString:model.user.uid]) {
        //不能评论自己
        return;
    }
    
    LMCommentInputView* inputView = [[LMCommentInputView alloc]init];
    [inputView startShow];
    inputView.inputText = ^(NSString* inputStr) {
        if (inputStr != nil && inputStr.length > 0) {
            NSString* tempPrevUidStr = model.user.uid;
            UInt32 tempPrevUid = (UInt32 )tempPrevUidStr.integerValue;
            
            CommentBuilder* builder = [Comment builder];
            [builder setArticleId:(UInt32 )self.articleId];
            [builder setText:inputStr];
            [builder setPrevId:(UInt32 )model.commentId];
            [builder setPrevUid:tempPrevUid];
            Comment* customComment = [builder build];
            
            PubCommentReqBuilder* reqBuilder = [PubCommentReq builder];
            [reqBuilder setComment:customComment];
            PubCommentReq* req = [reqBuilder build];
            NSData* reqData = [req data];
            
            [self showNetworkLoadingView];
            LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
            [networkTool postWithCmd:5 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                    if (apiRes.cmd == 5) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            [self showMBProgressHUDWithText:@"评论成功"];
                            
                            [self.tableView startRefresh];
                        }
                    }
                } @catch (NSException *exception) {
                    [self showMBProgressHUDWithText:NetworkFailedError];
                } @finally {
                    [self hideNetworkLoadingView];
                }
            } failureBlock:^(NSError *failureError) {
                [self showMBProgressHUDWithText:NetworkFailedError];
                [self hideNetworkLoadingView];
            }];
        }
    };
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
    self.page = 0;
    self.isEnd = NO;
    
    [self loadCommentDetailDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        [self.tableView stopRefresh];
        return;
    }
    
    [self loadCommentDetailDataWithPage:self.page isLoadMore:YES];
}

#pragma mark -LMCommentTableViewCellDelegate
-(void)didStartScrollCell:(LMCommentTableViewCell* )selectedCell {
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMCommentTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == selectedCell) {
            continue;
        }
        [cell showDelete:NO animation:YES];
    }
}

-(void)didClickCell:(LMCommentTableViewCell* )cell deleteButton:(UIButton* )btn {
    [self showNetworkLoadingView];
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMCommentModel* model = [self.dataArray objectAtIndex:indexPath.row];
    
    [self operationCommentWithType:CommentDoTypeCommentDel commentId:(UInt32 )model.commentId];
}

//
-(void)operationCommentWithType:(CommentDoType )type commentId:(UInt32 )commentId {
    CommentDoReqBuilder* reqBuilder = [CommentDoReq builder];
    [reqBuilder setCommentId:commentId];
    [reqBuilder setType:type];
    CommentDoReq* req = [reqBuilder build];
    NSData* reqData = [req data];
    
    __weak LMCommentDetailViewController* weakSelf = self;
    
    [weakSelf showNetworkLoadingView];
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 7) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    [weakSelf.tableView startRefresh];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NetworkFailedError];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:NetworkFailedError];
        [weakSelf hideNetworkLoadingView];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatShareNotifyName object:nil];
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
