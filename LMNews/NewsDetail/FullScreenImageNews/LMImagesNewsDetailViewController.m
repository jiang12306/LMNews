//
//  LMImagesNewsDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMImagesNewsDetailViewController.h"
#import "LMImagesNewsFullScreenImage.h"
#import "LMTool.h"
#import "LMImagesNewsFullScreenImage.h"
#import "UIImageView+WebCache.h"
#import "LMCommentView.h"
#import "LMCommentInputView.h"
#import "LMLoginAlertView.h"
#import "LMShareView.h"
#import "LMShareMessage.h"
#import "LMCommentDetailViewController.h"

@interface LMImagesNewsDetailViewController () <UIScrollViewDelegate, LMImagesNewsFullScreenImageDelegate>

@property (nonatomic, strong) UIView* navigationView;/**<头视图*/
@property (nonatomic, strong) UIButton* closeBtn;/**<关闭 按钮*/
@property (nonatomic, strong) UIImageView* mediaIV;/**<媒体 图像*/
@property (nonatomic, strong) UILabel* mediaNameLab;/**<媒体 名称*/
@property (nonatomic, strong) UILabel* subCountLab;/**<关注数 label*/
@property (nonatomic, strong) UIButton* subBtn;/**<关注 按钮*/
@property (nonatomic, assign) NSInteger subCount;/**<关注人数*/
@property (nonatomic, assign) BOOL isSub;/**<是否已关注*/
@property (nonatomic, assign) BOOL isCollect;/**<是否已收藏*/

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@property (nonatomic, strong) LMCommentView* commentView;
@property (nonatomic, assign) NSInteger upCount;
@property (nonatomic, copy) NSString* titleStr;
@property (nonatomic, copy) NSString* briefStr;
@property (nonatomic, copy) NSString* shareUrl;

@end

@implementation LMImagesNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    self.fd_prefersNavigationBarHidden = YES;
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.dataArray = [NSMutableArray array];
    
    [self loadImagesNewsData];
}

-(void)setupNavigationViewWithSource:(Source* )source {
    CGFloat naviHeight = 20 + 44;
    CGFloat startY = 20;
    if ([LMTool isIPhoneX]) {
        naviHeight = 88;
        startY = 40;
    }
    
    self.navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, naviHeight)];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationView];
    
    self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, startY + 7, 30, 30)];
    self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:25];
    [self.closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:self.closeBtn];
    
    self.mediaIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.closeBtn.frame.origin.x + self.closeBtn.frame.size.width + 10, startY + 2, 40, 40)];
    self.mediaIV.layer.cornerRadius = 20;
    self.mediaIV.layer.masksToBounds = YES;
    [self.navigationView addSubview:self.mediaIV];
    [self.mediaIV sd_setImageWithURL:[NSURL URLWithString:source.url] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    
    self.subBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 80, startY + 7, 75, 30)];
    self.subBtn.backgroundColor = [UIColor colorWithHex:subOrangeString];
    self.subBtn.layer.cornerRadius = 3;
    self.subBtn.layer.masksToBounds = YES;
    [self.subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.subBtn addTarget:self action:@selector(clickedSourceSubscriptionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:self.subBtn];
    
    self.mediaNameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.mediaIV.frame.origin.x + self.mediaIV.frame.size.width + 10, self.mediaIV.frame.origin.y, self.subBtn.frame.origin.x - 10 * 2 - self.mediaIV.frame.origin.x - self.mediaIV.frame.size.width, 20)];
    self.mediaNameLab.textColor = [UIColor colorWithHex:subOrangeString];
    self.mediaNameLab.font = [UIFont systemFontOfSize:16];
    [self.navigationView addSubview:self.mediaNameLab];
    self.mediaNameLab.text = source.sourceName;
    
    self.subCountLab = [[UILabel alloc]initWithFrame:CGRectMake(self.mediaNameLab.frame.origin.x, self.mediaNameLab.frame.origin.y + self.mediaNameLab.frame.size.height, self.mediaNameLab.frame.size.width, 20)];
    self.subCountLab.textColor = [UIColor colorWithHex:alreadyReadString];
    self.subCountLab.font = [UIFont systemFontOfSize:12];
    [self.navigationView addSubview:self.subCountLab];
    
    self.subCount = source.subCount;
    NSString* subStr = [NSString stringWithFormat:@"%ld人已关注", self.subCount];
    if (self.subCount > 1000) {
        subStr = @"999+人关注";
    }
    self.subCountLab.text = subStr;
    
    if (source.isSub) {
        self.isSub = YES;
    }else {
        self.isSub = NO;
    }
}

-(void)setIsSub:(BOOL)isSub {
    if (isSub) {
        [self.subBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    }else {
        [self.subBtn setTitle:@"+关注" forState:UIControlStateNormal];
    }
    _isSub = isSub;
}

-(void)setupScrollView {
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view insertSubview:self.scrollView belowSubview:self.navigationView];
    
    CGFloat spaceX = 0;
    
    for (NSInteger i = 0; i < self.dataArray.count; i ++) {
        TextPicVideo* tempPic = [self.dataArray objectAtIndex:i];
        
        LMImagesNewsFullScreenImage* imageVi = [[LMImagesNewsFullScreenImage alloc]initWithFrame:CGRectMake((self.view.frame.size.width + spaceX) * i, 0, self.view.frame.size.width, self.view.frame.size.height) textPic:tempPic];
        imageVi.tag = i;
        imageVi.delegate = self;
        [self.scrollView addSubview:imageVi];
    }
    self.scrollView.contentSize = CGSizeMake((self.view.frame.size.width + spaceX) * self.dataArray.count, 0);
}

-(void)setupToolBar {
    __weak LMImagesNewsDetailViewController* weakSelf = self;
    
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
        UIImage* tempImg = [UIImage imageNamed:@"share_Link"];
        NSString* tempImgStr = nil;
        for (TextPicVideo* textPic in weakSelf.dataArray) {
            tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:textPic.url];
            tempImgStr = textPic.url;
            break;
        }
        if (tempImg == nil) {
            tempImg = [UIImage imageNamed:@"share_Link"];
        }
        
        LMCommentDetailViewController* commentDetailVC = [[LMCommentDetailViewController alloc]init];
        commentDetailVC.articleTitle = weakSelf.titleStr;
        commentDetailVC.articleBrief = weakSelf.briefStr;
        commentDetailVC.articleImgUrl = tempImgStr;
        commentDetailVC.articleImg = tempImg;
        commentDetailVC.articleUrl = weakSelf.shareUrl;
        commentDetailVC.articleId = weakSelf.newsId;
        commentDetailVC.isMark = weakSelf.isCollect;
        commentDetailVC.commentCount = weakSelf.upCount;
        [weakSelf.navigationController pushViewController:commentDetailVC animated:YES];
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
                    for (TextPicVideo* textPic in weakSelf.dataArray) {
                        tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:textPic.url];
                        tempImgStr = textPic.url;
                        break;
                    }
                    if (tempImg == nil) {
                        tempImg = [UIImage imageNamed:@"share_Link"];
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
    [self.view insertSubview:self.commentView aboveSubview:self.scrollView];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat bottomY = screenRect.size.height - self.commentView.frame.size.height / 2;
//    if ([LMTool isIPhoneX]) {
//        bottomY = screenRect.size.height - self.commentView.frame.size.height / 2 - 40;
//    }
    self.commentView.center = CGPointMake(self.view.frame.size.width / 2, bottomY);
}

-(void)showCommentInputView {
    __weak LMImagesNewsDetailViewController* weakSelf = self;
    
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

-(void)clickedCloseButton:(UIButton* )sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    __weak LMImagesNewsDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    if (weakSelf.isSub) {
                        weakSelf.isSub = NO;
                    }else {
                        weakSelf.isSub = YES;
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

-(void)loadImagesNewsData {
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
                    NSArray* detailArr = res.qiwen;
                    for (TextPicVideo* textPicVideo in detailArr) {
                        if (textPicVideo.type == 1) {
                            
                            [self.dataArray addObject:textPicVideo];
                        }
                    }
                    self.upCount = res.commentCount;
                    self.titleStr = res.title;
                    self.briefStr = res.simpleText;
                    self.shareUrl =  res.shareUrl;
                    self.isCollect = NO;
                    if (res.isBookmark) {
                        self.isCollect = YES;
                    }
                    if (self.dataArray.count > 0) {
                        [self setupNavigationViewWithSource:res.source];
                        [self setupScrollView];
                        [self setupToolBar];
                    }
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

#pragma mark -LMImagesNewsFullScreenImageDelegate
-(void)imagesNewsFullScreenImageSetupFullScreen:(BOOL)isFullScreen {
    CGRect naviRect = self.navigationView.frame;
    CGRect toolRect = self.commentView.frame;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (isFullScreen == YES) {
        CGFloat naviHeight = 20 + 44;
        if ([LMTool isIPhoneX]) {
            naviHeight = 88;
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationView.frame = CGRectMake(0, 0 - naviHeight, naviRect.size.width, naviRect.size.height);
            self.commentView.frame = CGRectMake(0, screenRect.size.height, toolRect.size.width, toolRect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.navigationView.frame = CGRectMake(0, 0, naviRect.size.width, naviRect.size.height);
            self.commentView.frame = CGRectMake(0, screenRect.size.height - toolRect.size.height, toolRect.size.width, toolRect.size.height);
        } completion:^(BOOL finished) {
            
        }];
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
