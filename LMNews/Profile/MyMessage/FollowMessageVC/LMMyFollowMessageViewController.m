//
//  LMMyFollowMessageViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/25.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMyFollowMessageViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMMyFollowMessageTableViewCell.h"
#import "LMMyMessageModel.h"
#import "LMCommentInputView.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMMyFollowMessageViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation LMMyFollowMessageViewController

static NSString* followCellIdentifier = @"followCellIdentifier";

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
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, self.topY, self.view.frame.size.width, self.view.frame.size.height - self.topY - naviBarHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMMyFollowMessageTableViewCell class] forCellReuseIdentifier:followCellIdentifier];
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
    [self loadMyFollowMessageDataWithPage:self.page isLoadMore:NO];
}

-(void)loadMyFollowMessageDataWithPage:(NSInteger )page isLoadMore:(BOOL )isLoadMore {
    AboutMyCommentReqBuilder* builder = [AboutMyCommentReq builder];
    [builder setPage:(UInt32 )page];
    AboutMyCommentReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:23 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 23) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    AboutMyCommentRes* res = [AboutMyCommentRes parseFromData:apiRes.body];
                    
                    UInt32 pSize = res.psize;
                    NSArray* arr = res.coms;
                    if (arr == nil || arr.count <= pSize) {//最后一页
                        self.isEnd = YES;
                        [self.tableView setupNoMoreData];
                    }
                    
                    if (arr != nil && arr.count > 0) {
                        if (self.page == 0) {
                            [self.dataArray removeAllObjects];
                        }
                        
                        for (UserVsComment* vsComment in arr) {
                            LMMyFollowMessageModel* model = [[LMMyFollowMessageModel alloc]init];
                            model.comments = vsComment.comments;
                            model.user = vsComment.user;
                            model.articleId = vsComment.articleId;
                            model.isFold = NO;
                            if (model.comments != nil && model.comments.count > 0) {
                                if (model.comments.count > 1) {
                                    model.isFold = YES;
                                }
                                
                                NSString* nameStr = model.user.phoneNum;
                                if (model.user.nickname != nil && model.user.nickname.length > 0) {
                                    nameStr = model.user.nickname;
                                }
                                model.nickStr = nameStr;
                                model.nameWidth = [self caculateFollowMessageWidthWithText:nameStr maxHeight:20 maxLines:1 font:[UIFont systemFontOfSize:18]];
                                
                                Comment* tempComment = [model.comments objectAtIndex:0];
                                
                                model.timeStr = tempComment.cT;
                            }
                            
                            [self.dataArray addObject:model];
                        }
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

-(CGFloat)caculateFollowMessageWidthWithText:(NSString *)text maxHeight:(CGFloat)maxHeight maxLines:(NSInteger )maxLines font:(UIFont *)font {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, maxHeight)];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (font) {
        lab.font = font;
    }else {
        lab.font = [UIFont systemFontOfSize:18];
    }
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, maxHeight)];
    return labSize.width;
}

-(CGFloat )caculateFollowMessageHeightWithFont:(UIFont* )font maxWidth:(CGFloat )maxWidth text:(NSString* )text {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectZero];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    lab.font = font;
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    return labSize.height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, followMessageCellAvatorWIdth + 10)];
    vi.backgroundColor = [UIColor whiteColor];
    
    UIImageView* avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, followMessageCellAvatorWIdth, followMessageCellAvatorWIdth)];
    avatorIV.layer.cornerRadius = 25;
    avatorIV.layer.masksToBounds = YES;
    [avatorIV sd_setImageWithURL:[NSURL URLWithString:model.user.icon] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    [vi addSubview:avatorIV];
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(followMessageCellAvatorWIdth + 10 * 2, 10, model.nameWidth, 25)];
    nameLab.font = [UIFont systemFontOfSize:18];
    nameLab.textColor = [UIColor colorWithHex:themeOrangeString];
    nameLab.text = model.nickStr;
    [vi addSubview:nameLab];
    
    UIButton* replyBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 40, 25, 40, 20)];
    replyBtn.tag = section;
    [replyBtn setTitle:@"回复" forState:UIControlStateNormal];
    [replyBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
    replyBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [replyBtn addTarget:self action:@selector(clickedReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:replyBtn];
    
    UILabel* timeLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height, 130, 25)];
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.textColor = [UIColor colorWithHex:alreadyReadString];
    timeLab.text = model.timeStr;
    [vi addSubview:timeLab];
    
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    
    if (model.isFold) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        
        UIButton* spreadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        spreadBtn.backgroundColor = [UIColor whiteColor];
        spreadBtn.tag = section;
        [spreadBtn setTitle:@"⌵展开" forState:UIControlStateNormal];
        [spreadBtn setTitleColor:[UIColor colorWithHex:themeOrangeString] forState:UIControlStateNormal];
        spreadBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [spreadBtn addTarget:self action:@selector(clickedSpreadButton:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:spreadBtn];
        
        return vi;
    }else {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
        
        return vi;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return followMessageCellAvatorWIdth + 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    NSArray* arr = model.comments;
    if (arr == nil && arr.count == 0) {
        return 5;
    }
    if (model.isFold) {
        return 35;
    }
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    NSArray* arr = model.comments;
    if (arr == nil || arr.count == 0) {
        return 0;
    }
    if (model.isFold) {
        return 1;
    }else {
        NSArray* arr = model.comments;
        return arr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    NSArray* arr = model.comments;
    if (arr == nil || arr.count == 0) {
        return 0;
    }
    CGFloat cellHeight = 0;
    
    Comment* subCom = [arr objectAtIndex:row];
    RegUser* user = subCom.user;
    NSString* nickStr = user.phoneNum;
    if (user.nickname != nil && user.nickname.length > 0) {
        nickStr = user.nickname;
    }
    NSString* contentStr = subCom.text;
    NSString* totalStr = [NSString stringWithFormat:@"%@：%@", nickStr, contentStr];
    CGFloat strHeight = [self caculateFollowMessageHeightWithFont:[UIFont systemFontOfSize:16] maxWidth:self.view.frame.size.width - 10 * 2 text:totalStr];
    cellHeight += 20 + strHeight;
    
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    LMMyFollowMessageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:followCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMMyFollowMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:followCellIdentifier];
    }
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:section];
    if (model.isFold) {
        [cell showLineView:NO];
    }else {
        if (row == model.comments.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
    }
    Comment* subComment = [model.comments objectAtIndex:row];
    [cell setupMessageContentWithComment:subComment];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
    self.page = 0;
    self.isEnd = NO;
    
    [self loadMyFollowMessageDataWithPage:self.page isLoadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        [self.tableView stopLoadMoreData];
        return;
    }
    
    [self loadMyFollowMessageDataWithPage:self.page isLoadMore:YES];
}

-(void)clickedReplyButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:tag];
    
    __weak LMMyFollowMessageViewController* weakSelf = self;
    
    LoginedRegUser* user = [LMTool getLoginedRegUser];
    RegUser* otherUser = model.user;
    if ([otherUser.uid isEqualToString:user.user.uid]) {
        return;
    }
    UInt32 tempPrevId = 0;
    for (Comment* tempComment in model.comments) {
        RegUser* tempUser = tempComment.user;
        if (![tempUser.uid isEqualToString:user.user.uid]) {
            tempPrevId = tempComment.prevId;
            break;
        }
    }
    if (tempPrevId == 0) {
        return;
    }
    
    LMCommentInputView* inputView = [[LMCommentInputView alloc]init];
    [inputView startShow];
    inputView.inputText = ^(NSString* inputStr) {
        if (inputStr != nil && inputStr.length > 0) {
            NSString* tempPrevUidStr = otherUser.uid;
            UInt32 tempPrevUid = (UInt32 )tempPrevUidStr.integerValue;
            
            CommentBuilder* builder = [Comment builder];
            [builder setArticleId:model.articleId];
            [builder setText:inputStr];
            [builder setPrevId:tempPrevId];
            [builder setPrevUid:tempPrevUid];
            Comment* customComment = [builder build];
            
            PubCommentReqBuilder* reqBuilder = [PubCommentReq builder];
            [reqBuilder setComment:customComment];
            PubCommentReq* req = [reqBuilder build];
            NSData* reqData = [req data];
            
            [weakSelf showNetworkLoadingView];
            LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
            [networkTool postWithCmd:5 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                    if (apiRes.cmd == 5) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            [weakSelf showMBProgressHUDWithText:@"评论成功"];
                            
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
    };
}

-(void)clickedSpreadButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    LMMyFollowMessageModel* model = [self.dataArray objectAtIndex:tag];
    model.isFold = NO;
    
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:tag];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
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
