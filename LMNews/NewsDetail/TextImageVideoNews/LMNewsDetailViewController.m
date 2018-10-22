//
//  LMNewsDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMNewsDetailTextTableViewCell.h"
#import "LMNewsDetailImageTableViewCell.h"
#import "LMNewsDetailVideoTableViewCell.h"
#import "LMNewsDetailGifTableViewCell.h"
#import "LMCommentTableViewCell.h"
#import "LMRecommendModel.h"
#import "LMNewsDetailModel.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "LMCommentDetailViewController.h"
#import "LMTool.h"
#import "LMCommentView.h"
#import "LMFastLoginViewController.h"
#import "LMCommentInputView.h"
#import "UIImageView+WebCache.h"
#import "LMShareView.h"
#import "LMShareMessage.h"
#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendVideoTableViewCell.h"
#import "LMRecommendImagesTableViewCell.h"
#import "LMRecommendTextTableViewCell.h"
#import "XLPhotoBrowser.h"
#import "LMImagesNewsDetailViewController.h"
#import "MBProgressHUD.h"
#import "LMLoginAlertView.h"

@interface LMNewsDetailViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate, LMNewsDetailImageTableViewCellDelegate, LMNewsDetailGifTableViewCellDelegate, LMCommentTableViewCellDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic, strong) LMCommentView* commentView;

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* commentArray;/**<评论*/
@property (nonatomic, strong) NSMutableArray* recommendArray;/**<相关推荐*/
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, copy) NSString* titleStr;
@property (nonatomic, strong) UILabel* briefLab;
@property (nonatomic, copy) NSString* briefStr;
@property (nonatomic, assign) BOOL isCollect;
@property (nonatomic, assign) BOOL isSub;
@property (nonatomic, assign) NSInteger upCount;
@property (nonatomic, assign) CGFloat currentOffset;/**<*/

@property (nonatomic, copy) NSString* shareUrl;/**<新闻分享url*/

@property (nonatomic, strong) NSMutableArray* imagesArray;/**<*/

@end

@implementation LMNewsDetailViewController

static NSString* textCellIdentifier = @"textCellIdentifier";
static NSString* imageCellIdentifier = @"imageCellIdentifier";
static NSString* videoCellIdentifier = @"videoCellIdentifier";
static NSString* gifCellIdentifier = @"gifCellIdentifier";
static NSString* commentCellIdentifier = @"commentCellIdentifier";

static NSString* recommendImageCellIdentifier = @"recommendImageCellIdentifier";
static NSString* recommendVideoCellIdentifier = @"recommendVideoCellIdentifier";
static NSString* recommendImagesCellIdentifier = @"recommendImagesCellIdentifier";
static NSString* recommendTextCellIdentifier = @"recommendTextCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    
    CGFloat naviBarHeight = 64;
    CGFloat footerHeight = 44;
    if ([LMTool isIPhoneX]) {
        naviBarHeight = 88;
        footerHeight += 40;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviBarHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMNewsDetailTextTableViewCell class] forCellReuseIdentifier:textCellIdentifier];
    [self.tableView registerClass:[LMNewsDetailVideoTableViewCell class] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerClass:[LMNewsDetailImageTableViewCell class] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerClass:[LMNewsDetailGifTableViewCell class] forCellReuseIdentifier:gifCellIdentifier];
    [self.tableView registerClass:[LMCommentTableViewCell class] forCellReuseIdentifier:commentCellIdentifier];
    [self.tableView registerClass:[LMRecommendImageTableViewCell class] forCellReuseIdentifier:recommendImageCellIdentifier];
    [self.tableView registerClass:[LMRecommendVideoTableViewCell class] forCellReuseIdentifier:recommendVideoCellIdentifier];
    [self.tableView registerClass:[LMRecommendImagesTableViewCell class] forCellReuseIdentifier:recommendImagesCellIdentifier];
    [self.tableView registerClass:[LMRecommendTextTableViewCell class] forCellReuseIdentifier:recommendTextCellIdentifier];
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    //
    self.dataArray = [NSMutableArray array];
    self.commentArray = [NSMutableArray array];
    self.recommendArray = [NSMutableArray array];
    self.imagesArray = [NSMutableArray array];
    
    [self loadNewsDetailDataWithRefresh:NO];
    
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

-(void)setupTableHeaderViewWithSource:(Source* )source time:(NSString* )timeStr {
    if (self.headerView) {
        for (UIView* subView in self.headerView.subviews) {
            [subView removeFromSuperview];
        }
    }
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    CGFloat tempTitleOriginY = 0;
    if (self.titleStr != nil && self.titleStr.length > 0) {
        tempTitleOriginY = 10;
    }
    CGFloat tempTitleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:self.titleStr maxWidth:self.headerView.frame.size.width - 10 * 2 maxLines:0 font:[UIFont boldSystemFontOfSize:20]];
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, tempTitleOriginY, self.headerView.frame.size.width - 10 * 2, tempTitleHeight)];
    self.titleLab.font = [UIFont boldSystemFontOfSize:20];
    self.titleLab.numberOfLines = 0;
    self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLab.text = self.titleStr;
    [self.headerView addSubview:self.titleLab];
    
    UIImageView* mediaIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 15, 40, 40)];
    mediaIV.layer.cornerRadius = 20;
    mediaIV.layer.masksToBounds = YES;
    [mediaIV sd_setImageWithURL:[NSURL URLWithString:source.url] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    [self.headerView addSubview:mediaIV];
    
    CGFloat tempNameWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:source.sourceName maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:16]];
    if (tempNameWidth > self.view.frame.size.width - mediaIV.frame.size.width - 75 - 10 * 4) {
        tempNameWidth = self.view.frame.size.width - mediaIV.frame.size.width - 75 - 10 * 4;
    }
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(60, mediaIV.frame.origin.y, tempNameWidth, 20)];
    nameLab.font = [UIFont systemFontOfSize:16];
    nameLab.numberOfLines = 1;
    nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLab.textColor = [UIColor colorWithHex:themeOrangeString];
    nameLab.text = source.sourceName;
    [self.headerView addSubview:nameLab];
    
    CGFloat tempTimeWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:timeStr maxHeight:30 maxLines:1 font:[UIFont systemFontOfSize:14]];
    UILabel* timeLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height, tempTimeWidth, 20)];
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.textColor = [UIColor colorWithHex:alreadyReadString];
    timeLab.text = timeStr;
    [self.headerView addSubview:timeLab];
    
    UIButton* subBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 75, mediaIV.frame.origin.y + 5, 75, 30)];
    subBtn.backgroundColor = [UIColor colorWithHex:subOrangeString];
    subBtn.layer.cornerRadius = 3;
    subBtn.layer.masksToBounds = YES;
    subBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    subBtn.tag = source.sourceId;
    if (source.isSub) {
        self.isSub = YES;
        [subBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    }else {
        self.isSub = NO;
        [subBtn setTitle:@"+关注" forState:UIControlStateNormal];
    }
    [subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [subBtn addTarget:self action:@selector(clickedSourceSubscriptionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:subBtn];
    
    CGFloat tempBriefOriginY = 0;
    if (self.briefStr != nil && self.briefStr.length > 0) {
        tempBriefOriginY = 15;
    }
    CGFloat tempBriefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:self.briefStr maxWidth:self.titleLab.frame.size.width maxLines:0 font:[UIFont systemFontOfSize:16]];
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, mediaIV.frame.origin.y + mediaIV.frame.size.height + tempBriefOriginY, self.headerView.frame.size.width - 10 * 2, tempBriefHeight)];
    self.briefLab.font = [UIFont systemFontOfSize:16];
    self.briefLab.textColor = [UIColor grayColor];
    [self.headerView addSubview:self.briefLab];
    
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 15);
    
    self.tableView.tableHeaderView = self.headerView;
}

-(void)clickedSourceSubscriptionButton:(UIButton* )sender {
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
    
    SourceDoType type = SourceDoTypeSourceFollow;
    if (self.isSub) {
        type = SourceDoTypeSourceUnfollow;
    }
    [self showNetworkLoadingView];
    
    SourceDoReqBuilder* builder = [SourceDoReq builder];
    [builder setSourceId:(UInt32 )sender.tag];
    [builder setType:type];
    SourceDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMNewsDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    if (weakSelf.isSub) {
                        weakSelf.isSub = NO;
                        [sender setTitle:@"+关注" forState:UIControlStateNormal];
                    }else {
                        weakSelf.isSub = YES;
                        [sender setTitle:@"取消关注" forState:UIControlStateNormal];
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

-(void)setupToolBar {
    __weak LMNewsDetailViewController* weakSelf = self;
    
    self.commentView = [[LMCommentView alloc]init];
    [self.commentView setupCommentCount:self.upCount];
    [self.commentView setupCollectedState:self.isCollect];
    self.commentView.commentBlock = ^(BOOL didStart) {
        if (didStart) {
            LoginedRegUser* user = [LMTool getLoginedRegUser];
            if (user == nil) {
                LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
                loginAV.loginBlock = ^(BOOL didLogined) {
                    if (didLogined) {
                        [weakSelf showCommentInputView];
                    }
                };
                [loginAV startShow];
                
                return;
            }
            
            [weakSelf showCommentInputView];
        }
    };
    self.commentView.numBlock = ^(BOOL showComment) {
        if (weakSelf.dataArray == nil || weakSelf.dataArray.count == 0) {
            return;
        }
        NSInteger row = 0;
        NSInteger section = 0;
        if (showComment) {
            weakSelf.currentOffset = weakSelf.tableView.contentOffset.y;
            if (weakSelf.tableView.numberOfSections == 1) {
                row = weakSelf.dataArray.count - 1;
                section = 0;
            }else if (weakSelf.tableView.numberOfSections == 2) {
                section = 1;
            }else if (weakSelf.tableView.numberOfSections == 3) {
                section = 1;
            }
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }else {
            weakSelf.tableView.contentOffset = CGPointMake(0, weakSelf.currentOffset);
            
//            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    self.commentView.collectBlock = ^(BOOL didStart) {
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
        
        [weakSelf showNetworkLoadingView];
        
        BookmarkDoReqBuilder* builder = [BookmarkDoReq builder];
        [builder setArticleId:(UInt32 )weakSelf.newsId];
        BookmarkDoType markType = BookmarkDoTypeArticleBookmark;
        if (weakSelf.isCollect) {
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
                        if (weakSelf.isCollect) {
                            weakSelf.isCollect = NO;
                            [weakSelf.commentView setupCollectedState:NO];
                        }else {
                            weakSelf.isCollect = YES;
                            [weakSelf.commentView setupCollectedState:YES];
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
    };
    self.commentView.shareBlock = ^(BOOL didStart) {
        if (didStart) {
            LMShareView* shareView = [[LMShareView alloc]init];
            shareView.shareBlock = ^(LMShareViewType shareType) {
                if (weakSelf.shareUrl != nil && weakSelf.shareUrl.length > 0) {
                    UIImage* tempImg = [UIImage imageNamed:@"share_Link"];
                    NSString* tempImgStr = nil;
                    for (LMNewsDetailModel* model in weakSelf.dataArray) {
                        if (model.isSucceed && model.img != nil) {
                            tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:model.url];
                            tempImgStr = model.url;
                            break;
                        }
                    }
                    if (tempImg != nil && (shareType == LMShareViewTypeWeChat || shareType == LMShareViewTypeWeChatMoment)) {
                        NSData* imgData = UIImageJPEGRepresentation(tempImg, 0.5);
                        tempImg = [UIImage imageWithData:imgData];
                        if (imgData.length / 1024 > 32) {//图片大于32KB，给默认图
                            tempImg = [UIImage imageNamed:@"share_Link"];
                        }
                    }
                    if (tempImg == nil) {
                        tempImg = [UIImage imageNamed:@"share_Link"];
                    }
                    
                    if (shareType == LMShareViewTypeWeChat) {
                        [LMShareMessage shareToWeChatWithTitle:weakSelf.titleStr description:weakSelf.briefStr urlStr:weakSelf.shareUrl isMoment:NO img:tempImg];
                    }else if (shareType == LMShareViewTypeWeChatMoment) {
                        [LMShareMessage shareToWeChatWithTitle:weakSelf.titleStr description:weakSelf.briefStr urlStr:weakSelf.shareUrl isMoment:YES img:tempImg];
                    }else if (shareType == LMShareViewTypeQQ) {
                        [LMShareMessage shareToQQWithTitle:weakSelf.titleStr description:weakSelf.briefStr urlStr:weakSelf.shareUrl isZone:NO imgStr:tempImgStr];
                    }else if (shareType == LMShareViewTypeQQZone) {
                        [LMShareMessage shareToQQWithTitle:weakSelf.titleStr description:weakSelf.briefStr urlStr:weakSelf.shareUrl isZone:YES imgStr:tempImgStr];
                    }else if (shareType == LMShareViewTypeCopyLink) {
                        [[UIPasteboard generalPasteboard]setString:weakSelf.shareUrl];
                        
                        [weakSelf showMBProgressHUDWithText:@"复制成功"];
                    }
                }
            };
            [shareView startShow];
        }
    };
    [self.view addSubview:self.commentView];
    self.commentView.center = CGPointMake(self.view.frame.size.width / 2, self.tableView.frame.origin.y + self.tableView.frame.size.height - self.commentView.frame.size.height / 2);
}

-(void)showCommentInputView {
    __weak LMNewsDetailViewController* weakSelf = self;
    
    LMCommentInputView* inputView = [[LMCommentInputView alloc]init];
    [inputView startShow];
    inputView.inputText = ^(NSString* inputStr) {
        if (inputStr != nil && inputStr.length > 0) {
            CommentBuilder* builder = [Comment builder];
            [builder setArticleId:(UInt32 )self.newsId];
            [builder setText:inputStr];
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
                            weakSelf.upCount ++;
                            [weakSelf.commentView setupCommentCount:weakSelf.upCount];
                            
                            [weakSelf showMBProgressHUDWithText:@"评论成功"];
                            
                            [weakSelf loadNewsDetailDataWithRefresh:YES];
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

-(void)loadNewsDetailDataWithRefresh:(BOOL )isRefresh {
    [self showNetworkLoadingView];
    
    QiWenDetailReqBuilder* builder = [QiWenDetailReq builder];
    [builder setId:(UInt32)self.newsId];
    QiWenDetailReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 1) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    QiWenDetailRes* res = [QiWenDetailRes parseFromData:apiRes.body];
                    NSString* timeString = [LMTool convertTimeStringWithFormartterString:@"YYYY-MM-dd" TimeStamp:res.t];
                    self.upCount = res.commentCount;
                    Source* source = res.source;
                    self.titleStr = res.title;
                    self.briefStr = res.simpleText;
                    self.shareUrl = res.shareUrl;
                    self.isCollect = NO;
                    if (res.isBookmark) {
                        self.isCollect = YES;
                    }
                    //清空数据
                    [self.dataArray removeAllObjects];
                    [self.commentArray removeAllObjects];
                    [self.recommendArray removeAllObjects];
                    
                    NSArray* commentArr = res.comments;
                    if (commentArr != nil && commentArr.count > 0) {
                        for (Comment* tempCom in commentArr) {
                            LMCommentModel* model = [[LMCommentModel alloc]init];
                            model.commentId = tempCom.id;
                            if (tempCom.prevUser != nil) {
                                NSString* nickStr = tempCom.prevUser.phoneNum;
                                if (tempCom.prevUser.nickname != nil && tempCom.prevUser.nickname.length > 0) {
                                    nickStr = tempCom.prevUser.nickname;
                                }
                                if (nickStr != nil && nickStr.length > 0) {
                                    model.text = [NSString stringWithFormat:@"@%@ 评论 %@", nickStr, tempCom.text];
                                }else {
                                    model.text = tempCom.text;
                                }
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
                            model.time = tempCom.cT;
                            model.timeWidth = 130;
                            model.isFold = NO;
                            if (model.text != nil && model.text.length > 0) {
                                [LMCommentModel caculateCommentLabelHeightWithText:model.text maxWidth:(self.view.frame.size.width - 10 * 2) maxLines:4 font:[UIFont systemFontOfSize:CommentContentFontSize] block:^(CGFloat labHeight, CGFloat labOriginHeight, NSInteger lines) {
                                    if (labOriginHeight > labHeight) {
                                        model.isFold = YES;
                                    }
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
                            
                            [self.commentArray addObject:model];
                        }
                    }
                    
                    NSArray* arr = res.qiwen;
                    if (arr != nil && arr.count > 0) {
                        for (TextPicVideo* membVideo in arr) {
                            LMNewsDetailModel* model = [[LMNewsDetailModel alloc]init];
                            model.url = membVideo.url;
                            model.type = membVideo.type;
                            model.gif = membVideo.gif;
                            model.isSucceed = NO;
                            model.isGif = NO;
                            if (membVideo.type == 1) {
                                if (membVideo.gif != nil && membVideo.gif.length > 0) {
                                    model.isGif = YES;
                                }else {
                                    UIImage* tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:model.url];
                                    if (tempImg) {
                                        model.isSucceed = YES;
                                        model.img = tempImg;
                                        if (membVideo.width && membVideo.height) {
                                            CGSize tempImgSize = [LMNewsDetailModel caculateImageSizeWithImageWidth:membVideo.width imageHeight:membVideo.height maxWidth:self.view.frame.size.width - 10 * 2];
                                            model.imgWidth = tempImgSize.width;
                                            model.imgHeight = tempImgSize.height;
                                        }else {
                                            CGSize imgSize = [LMNewsDetailModel caculateImageHeightWithImage:tempImg maxWidth:self.view.frame.size.width - 10 * 2];
                                            model.imgWidth = imgSize.width;
                                            model.imgHeight = imgSize.height;
                                        }
                                    }
                                }
                            }
                            
                            NSString* str = membVideo.text;
                            CGFloat textHeight = 0;
                            if (str != nil) {
                                NSString* htmlStr = [NSString stringWithFormat:@"<span style=\"line-height:27px;\"><font size=\"5\">%@</font></span>", str];
                                NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                                textHeight = [LMNewsDetailModel caculateTextViewHeightWithText:attributedStr maxWidth:self.view.frame.size.width - 10 * 2 font:[UIFont systemFontOfSize:16]];
                                model.text = attributedStr;
                            }
                            model.titleHeight = textHeight;
                            
                            [self.dataArray addObject:model];
                        }
                    }
                    NSArray* tempRecommendArr = res.relationArticle;
                    if (tempRecommendArr != nil && tempRecommendArr.count > 0) {
                        for (ArticleSimple* simple in tempRecommendArr) {
                            LMRecommendModel* model = [LMRecommendModel convertExploreDataToModelWithArticleSimple:simple];
                            [self.recommendArray addObject:model];
                        }
                    }
                    
                    if (!isRefresh) {
                        //tableHeaderView
                        [self setupTableHeaderViewWithSource:source time:timeString];
                        
                        [self setupToolBar];
                    }
                    
                    //
                    [self.tableView reloadData];
                    
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL isRecommend = NO;
    if (section == 1) {
        if (self.commentArray.count > 0) {
            
        }else {
            isRecommend = YES;
        }
    }else if (section == 2) {
        isRecommend = YES;
    }
    if (isRecommend) {
        UIView* tempHeaderVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        tempHeaderVi.backgroundColor = [UIColor whiteColor];
        UILabel* moreRecommendLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 10 * 2, tempHeaderVi.frame.size.height)];
        moreRecommendLab.font = [UIFont boldSystemFontOfSize:16];
        moreRecommendLab.text = @"相关推荐";
        [tempHeaderVi addSubview:moreRecommendLab];
        return tempHeaderVi;
    }
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        if (self.commentArray.count > 0) {
            UIView* footerVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
            footerVi.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
            UIView* whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, footerVi.frame.size.width, footerVi.frame.size.height - 10)];
            whiteView.backgroundColor = [UIColor whiteColor];
            [footerVi addSubview:whiteView];
            UIButton* moreCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, self.view.frame.size.width - 10 * 2, 30)];
            moreCommentBtn.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
            [moreCommentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [moreCommentBtn setTitle:@"查看更多热评" forState:UIControlStateNormal];
            [moreCommentBtn addTarget:self action:@selector(clickedMoreCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            moreCommentBtn.layer.cornerRadius = 5;
            moreCommentBtn.layer.masksToBounds = YES;
            moreCommentBtn.layer.borderColor = [UIColor grayColor].CGColor;
            moreCommentBtn.layer.borderWidth = 0.5f;
            [whiteView addSubview:moreCommentBtn];
            return footerVi;
        }
    }
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    if (self.dataArray.count > 0) {
        vi.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    }else {
        vi.backgroundColor = [UIColor clearColor];
    }
    
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (self.commentArray.count > 0) {
            
        }else {
            return 40;
        }
    }else if (section == 2) {
        return 40;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        if (self.commentArray.count > 0) {
            return 80;
        }
    }
    return 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.commentArray.count > 0) {
        if (self.recommendArray.count > 0) {
            return 3;
        }else {
            return 2;
        }
    }else {
        if (self.recommendArray.count > 0) {
            return 2;
        }else {
            return 1;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArray.count;
    }else if (section == 1) {
        if (self.commentArray.count > 0) {
            return self.commentArray.count;
        }else {
            return self.recommendArray.count;
        }
    }else if (section == 2) {
        return self.recommendArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL isRecommend = NO;
    if (section == 0) {
        LMNewsDetailModel* model = [self.dataArray objectAtIndex:row];
        NSInteger type = model.type;
        
        CGFloat cellHeight = 20;
        cellHeight += model.titleHeight;
        
        if (type == 0) {//文本
            
        }else if (type == 1) {//图片
            if (model.text != nil && model.text.length > 0) {
                cellHeight += 10;//文字与图片之间的间距
            }
            if (model.isGif) {
                if (model.isSucceed) {
                    cellHeight += model.imgHeight;
                }else {
                    cellHeight += (self.view.frame.size.width - 10 * 2) * 0.618;
                }
            }else {
                if (model.isSucceed) {
                    cellHeight += model.imgHeight;
                }else {
                    if (model.imgHeight) {
                        cellHeight += model.imgHeight;
                    }else {
                        cellHeight += self.view.frame.size.width - 10 * 2;
                    }
                }
            }
        }else if (type == 2) {//视频
            if (model.text != nil && model.text.length > 0) {
                cellHeight += 10;//文字与视频之间的间距
            }
            cellHeight += (self.view.frame.size.width - 10 * 2) * 0.618;
        }
        return cellHeight;
    }else if (section == 1) {
        if (self.commentArray.count > 0) {
            
        }else {
            isRecommend = YES;
        }
        
    }else if (section == 2) {
        isRecommend = YES;
    }
    if (isRecommend) {
        LMRecommendModel* model = [self.recommendArray objectAtIndex:row];
        return model.cellHeight;
    }else {
        LMCommentModel* model = [self.commentArray objectAtIndex:row];
        
        CGFloat cellHeight = 30 + CommentAvatorIVWidth;
        if (model.isFold) {
            if (model.contentHeight > 0) {
                cellHeight += model.contentHeight;
            }
        }else {
            if (model.contentOriginHeight > 0) {
                cellHeight += model.contentOriginHeight;
            }
        }
        
        return cellHeight;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL isRecommend = NO;
    if (section == 0) {
        LMNewsDetailModel* model = [self.dataArray objectAtIndex:row];
        NSInteger type = model.type;
        if (type == 0) {
            LMNewsDetailTextTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMNewsDetailTextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
            }
            [cell showLineView:NO];
            
            
            [cell setupTextContent:model];
            
            return cell;
        }else if (type == 1) {
            if (model.isGif) {
                LMNewsDetailGifTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:gifCellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[LMNewsDetailGifTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gifCellIdentifier];
                }
                [cell showLineView:NO];
                cell.delegate = self;
                
                [cell setupGifContent:model indexPath:indexPath];
                
                return cell;
            }else {
                LMNewsDetailImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[LMNewsDetailImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
                }
                [cell showLineView:NO];
                cell.delegate = self;
                
                [cell setupImageContent:model indexPath:indexPath];
                
                return cell;
            }
        }else if (type == 2) {
            LMNewsDetailVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMNewsDetailVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
            }
            [cell showLineView:NO];
            
            [cell setupVideoContent:model];
            return cell;
        }
    }else if (section == 1) {
        if (self.commentArray.count > 0) {
            
        }else {
            isRecommend = YES;
        }
    }else if (section == 2) {
        isRecommend = YES;
    }
    if (isRecommend) {
        LMRecommendModel* model = [self.recommendArray objectAtIndex:row];
        LMRecommendModelCellStyle cellStyle = model.cellStyle;
        if (cellStyle == LMRecommendImageTableViewCellStyle) {
            LMRecommendImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:recommendImageCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMRecommendImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendImageCellIdentifier];
            }
            [cell setupContentWithModel:model];
            
            return cell;
        }else if (cellStyle == LMRecommendVideoTableViewCellStyle) {
            LMRecommendVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:recommendVideoCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMRecommendVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendVideoCellIdentifier];
            }
            [cell setupContentWithModel:model];
            
            return cell;
        }else if (cellStyle == LMRecommendImagesTableViewCellStyle) {
            LMRecommendImagesTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:recommendImagesCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMRecommendImagesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendImagesCellIdentifier];
            }
            [cell setupContentWithModel:model];
            
            return cell;
        }else if (cellStyle == LMRecommendTextTableViewCellStyle) {
            LMRecommendTextTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:recommendTextCellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[LMRecommendTextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recommendTextCellIdentifier];
            }
            [cell setupContentWithModel:model];
            
            return cell;
        }
    }else {
        LMCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:commentCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
        }
        cell.delegate = self;
        
        RegUser* user = [LMTool getLoginedRegUser].user;
        LMCommentModel* model = [self.commentArray objectAtIndex:row];
        [cell setupContentWithModel:model];
        
        [cell canSpan:NO];
        if ([model.user.uid isEqualToString:user.uid]) {
            [cell canSpan:YES];
        }
        
        __weak LMNewsDetailViewController* weakSelf = self;
        __weak LMCommentModel* weakModel = model;
        
        cell.likeBlock = ^(BOOL isLike, LMCommentTableViewCell *likeCell) {
            if (isLike) {
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
                [weakSelf operationCommentWithType:CommentDoTypeCommentUp commentId:(UInt32 )weakModel.commentId];
            }
        };
        
        cell.unlikeBlock = ^(BOOL isUnlike, LMCommentTableViewCell *unlikeCell) {
            if (isUnlike) {
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
                [weakSelf operationCommentWithType:CommentDoTypeCommentDown commentId:(UInt32 )weakModel.commentId];
            }
        };
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL isRecommend = NO;
    if (section == 1) {
        if (self.commentArray.count > 0) {
            
        }else {
            isRecommend = YES;
        }
    }else if (section == 2) {
        isRecommend = YES;
    }
    if (isRecommend) {
        LMRecommendModel* model = [self.recommendArray objectAtIndex:row];
        model.alreadyRead = YES;
        
        LMArticleSimple* articleSimple = model.article;
        //
        [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:articleSimple.articleId isRead:YES];
        
        if (articleSimple.isAllPic) {
            LMImagesNewsDetailViewController* imagesDetailVC = [[LMImagesNewsDetailViewController alloc]init];
            imagesDetailVC.newsId = articleSimple.articleId;
            [self.navigationController pushViewController:imagesDetailVC animated:YES];
        }else {
            LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
            newsDetailVC.newsId = articleSimple.articleId;
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
}

#pragma mark -LMNewsDetailImageTableViewCellDelegate
-(void)imageTableViewCellLoadImageSucceed:(BOOL)isSucceed cell:(LMNewsDetailImageTableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    if (isSucceed) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        });
    }else {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)imageTableViewCellTappedImageView:(LMNewsDetailImageTableViewCell *)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    LMNewsDetailModel* model = [self.dataArray objectAtIndex:row];
    
    NSInteger clickedIndex = 0;
    if (self.imagesArray == nil || self.imagesArray.count == 0) {
        for (NSInteger i = 0; i < self.dataArray.count; i ++) {
            LMNewsDetailModel* cellModel = [self.dataArray objectAtIndex:i];
            if (cellModel.type == 1 && !cellModel.isGif && cellModel.url != nil && cellModel.url.length > 0) {
                [self.imagesArray addObject:cellModel.url];
                if ([model.url isEqualToString:cellModel.url]) {
                    clickedIndex = self.imagesArray.count - 1;
                }
            }
        }
    }else {
        for (NSInteger i = 0; i < self.imagesArray.count; i ++) {
            NSString* tempImgStr = [self.imagesArray objectAtIndex:i];
            if ([model.url isEqualToString:tempImgStr]) {
                clickedIndex = i;
                break;
            }
        }
    }
    
    if (clickedIndex < 0) {
        clickedIndex = 0;
    }
    if (self.imagesArray == nil || self.imagesArray.count == 0) {
        return;
    }
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.imagesArray currentImageIndex:clickedIndex];
    [browser setActionSheetWithTitle:@"选项" delegate:self cancelButtonTitle:nil deleteButtonTitle:nil otherButtonTitles:@"保存图片", nil];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

#pragma mark -XLPhotoBrowserDatasource
-(void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex {
    if (actionSheetindex == 0) {
        @try {
            NSString* imgStr = [self.imagesArray objectAtIndex:currentImageIndex];
            UIImage* tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:imgStr];
            if (tempImg) {
                UIImageWriteToSavedPhotosAlbum(tempImg, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString* hudStr = @"保存成功";
    if (error != nil) {
        hudStr = @"保存失败";
    }
    NSArray* windowsArr = [UIApplication sharedApplication].windows;
    UIWindow* currentWindow = [windowsArr lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:currentWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hudStr;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

#pragma mark -LMNewsDetailGifTableViewCellDelegate
-(void)gifTableViewCellLoadImageSucceed:(BOOL)isSucceed cell:(LMNewsDetailGifTableViewCell *)cell model:(LMNewsDetailModel *)model indexPath:(NSIndexPath *)indexPath {
    if (isSucceed) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark -LMCommentTableViewCellDelegate
-(void)didStartScrollCell:(LMCommentTableViewCell* )selectedCell {
    NSInteger section = 0;
    if (self.dataArray.count == 0) {
        section = 1;
    }
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        UITableViewCell* indexCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([indexCell isKindOfClass:[LMCommentTableViewCell class]]) {
            LMCommentTableViewCell* cell = (LMCommentTableViewCell* )indexCell;
            if (cell == selectedCell) {
                continue;
            }
            [cell showDelete:NO animation:YES];
        }
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
    
    __weak LMNewsDetailViewController* weakSelf = self;
    
    [weakSelf showNetworkLoadingView];
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 7) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    [weakSelf loadNewsDetailDataWithRefresh:YES];
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

-(void)clickedMoreCommentButton:(UIButton* )sender {
    UIImage* tempImg = [UIImage imageNamed:@"share_Link"];
    NSString* tempImgStr = nil;
    for (LMNewsDetailModel* model in self.dataArray) {
        if (model.isSucceed && model.img != nil) {
            tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:model.url];
            tempImgStr = model.url;
            break;
        }
    }
    if (tempImg == nil) {
        tempImg = [UIImage imageNamed:@"share_Link"];
    }
    
    LMCommentDetailViewController* commentDetailVC = [[LMCommentDetailViewController alloc]init];
    commentDetailVC.articleTitle = self.titleStr;
    commentDetailVC.articleBrief = self.briefStr;
    commentDetailVC.articleImgUrl = tempImgStr;
    commentDetailVC.articleImg = tempImg;
    commentDetailVC.articleUrl = self.shareUrl;
    commentDetailVC.articleId = self.newsId;
    commentDetailVC.isMark = self.isCollect;
    commentDetailVC.commentCount = self.upCount;
    [self.navigationController pushViewController:commentDetailVC animated:YES];
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
