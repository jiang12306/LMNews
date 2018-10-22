//
//  LMHomeNewsViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMHomeNewsViewController.h"
#import "LMRecommendViewController.h"
#import "LMHomeRightBarButtonItemView.h"
#import "LMMyMessageViewController.h"
#import "LMHomeNavigationBarView.h"
#import "LMTool.h"

@interface LMHomeNewsViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) NSTimer* timer;/**<定时器 取系统消息*/
@property (nonatomic, assign) NSInteger timeCount;/**<时间间隔 取系统消息*/
@property (nonatomic, assign) NSInteger currentCount;/**<当前时间 取系统消息*/

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* titleBar;
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UIButton* followBtn;
@property (nonatomic, strong) UIButton* recommendBtn;
@property (nonatomic, strong) UIButton* hotBtn;
@property (nonatomic, assign) ListType currentType;

@end

@implementation LMHomeNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    CGFloat statusBarHeight = 20;
    if ([LMTool isIPhoneX]) {
        statusBarHeight = 44;
    }
    UIView* naviBarView = [[LMHomeNavigationBarView alloc]init];
    [self.view addSubview:naviBarView];
    
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, naviBarView.frame.size.height - statusBarHeight)];
    navTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    navTitleLabel.textColor = [UIColor colorWithHex:themeOrangeString];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.text = @"奇闻";
    [naviBarView addSubview:navTitleLabel];
    navTitleLabel.center = CGPointMake(naviBarView.frame.size.width / 2, naviBarView.frame.size.height / 2 + statusBarHeight / 2);
    
    __weak LMHomeNewsViewController* weakSelf = self;
    LMHomeRightBarButtonItemView* rightItem = [[LMHomeRightBarButtonItemView alloc]init];
    rightItem.clickBlock = ^(BOOL didClick) {
        LMMyMessageViewController* messageVC = [[LMMyMessageViewController alloc]init];
        [weakSelf.navigationController pushViewController:messageVC animated:YES];
    };
    [naviBarView addSubview:rightItem];
    rightItem.center = CGPointMake(naviBarView.frame.size.width - 30, navTitleLabel.center.y);
    
    
    //取未读消息
    [self loadSystemMessageData];
    
    self.titleBar = [[UIView alloc]initWithFrame:CGRectMake(0, naviBarView.frame.origin.y + naviBarView.frame.size.height, self.view.frame.size.width, 30)];
    self.titleBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleBar];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.titleBar.frame.origin.y + self.titleBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.titleBar.frame.origin.y - self.titleBar.frame.size.height)];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, 0);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view insertSubview:self.scrollView belowSubview:self.titleBar];
    
    CGFloat btnWidth = 60;
    
    self.recommendBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, self.titleBar.frame.size.height)];
    [self.recommendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.recommendBtn setTitle:@"推荐" forState:UIControlStateNormal];
    [self.recommendBtn addTarget:self action:@selector(clickedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBar addSubview:self.recommendBtn];
    self.recommendBtn.center = CGPointMake(self.titleBar.center.x, self.titleBar.frame.size.height / 2);
    
    self.followBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, self.titleBar.frame.size.height)];
    [self.followBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
    [self.followBtn addTarget:self action:@selector(clickedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBar addSubview:self.followBtn];
    self.followBtn.center = CGPointMake(self.titleBar.center.x + btnWidth, self.titleBar.frame.size.height / 2);
    
    self.hotBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, self.titleBar.frame.size.height)];
    [self.hotBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hotBtn setTitle:@"热点" forState:UIControlStateNormal];
    [self.hotBtn addTarget:self action:@selector(clickedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBar addSubview:self.hotBtn];
    self.hotBtn.center = CGPointMake(self.titleBar.center.x - btnWidth, self.titleBar.frame.size.height / 2);
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.titleBar.frame.size.height - 1, btnWidth, 1)];
    self.lineView.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    [self.titleBar addSubview:self.lineView];
    self.lineView.center = CGPointMake(self.recommendBtn.center.x, self.lineView.center.y);
    
    
    self.currentType = ListTypeTRecommend;
    [self clickedTypeButton:self.recommendBtn];
    
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshHomeNews) name:@"clickedTabBarRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartLoginOut) name:@"userDidLoginOut" object:nil];
}

-(void)loadSystemMessageData {
    __weak LMHomeNewsViewController* weakSelf = self;
    
    SysMsgListReqBuilder* builder = [SysMsgListReq builder];
    [builder setPage:0];
    SysMsgListReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:21 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 21) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SysMsgListRes* res = [SysMsgListRes parseFromData:apiRes.body];
                    NSArray* arr = res.sysmsgs;
                    NSInteger timeSpace = res.nT;//时间间隔
                    
                    weakSelf.timeCount = timeSpace;
                    weakSelf.currentCount = 0;
                    [weakSelf setupTimer];
                    
                    if (arr != nil && arr.count > 0) {
                        BOOL isUnread = NO;
                        for (SysMsg* msg in arr) {
                            if (!msg.isRead) {
                                isUnread = YES;
                                break;
                            }
                        }
                        //是否有未读消息
                        [LMHomeRightBarButtonItemView setupNewMessage:isUnread];
                    }
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

-(void)setupTimer {
    __weak LMHomeNewsViewController* weakSelf = self;
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(startCount) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
    }else {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

-(void)startCount {
    __weak LMHomeNewsViewController* weakSelf = self;
    
    self.currentCount ++;
    if (self.currentCount >= self.timeCount) {
        if (weakSelf.timer) {
            [weakSelf.timer setFireDate:[NSDate distantFuture]];
            [weakSelf.timer invalidate];
        }
        
        [weakSelf loadSystemMessageData];
    }
}

-(void)setCurrentType:(ListType)currentType {
    BOOL isContain = NO;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMRecommendViewController class]]) {
            LMRecommendViewController* exploreDetailVC = (LMRecommendViewController* )vc;
            if (exploreDetailVC.homeType == currentType) {
                isContain = YES;
                break;
            }
        }
    }
    CGFloat offsetCount = 0;
    CGFloat centerX = self.recommendBtn.center.x;
    if (currentType == ListTypeTHot) {
        offsetCount = 0;
        centerX = self.hotBtn.center.x;
    }else if (currentType == ListTypeTRecommend) {
        offsetCount = 1;
        centerX = self.recommendBtn.center.x;
    }else if (currentType == ListTypeTFollow) {
        offsetCount = 2;
        centerX = self.followBtn.center.x;
    }
    
    if (!isContain) {
        LMRecommendViewController* recommendVC = [[LMRecommendViewController alloc]init];
        recommendVC.homeType = currentType;
        recommendVC.view.frame = CGRectMake(self.scrollView.frame.size.width * offsetCount, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self addChildViewController:recommendVC];
        [self.scrollView addSubview:recommendVC.view];
    }
    
    CGFloat centerY = self.lineView.center.y;
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.center = CGPointMake(centerX, centerY);
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * offsetCount, 0);
    }];
    
    _currentType = currentType;
}

-(void)clickedTypeButton:(UIButton* )sender {
    CGFloat fontSize = 18;
    CGFloat bigSize = 20;
    self.followBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.recommendBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.hotBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    
    ListType tempType = ListTypeTHot;
    if (sender == self.hotBtn) {
        tempType = ListTypeTHot;
        self.hotBtn.titleLabel.font = [UIFont boldSystemFontOfSize:bigSize];
    }else if (sender == self.recommendBtn) {
        tempType = ListTypeTRecommend;
        self.recommendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:bigSize];
    }else if (sender == self.followBtn) {
        tempType = ListTypeTFollow;
        self.followBtn.titleLabel.font = [UIFont boldSystemFontOfSize:bigSize];
    }
    if (self.currentType != tempType) {
        self.currentType = tempType;
    }
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        int page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        if (page == 0) {
            [self clickedTypeButton:self.hotBtn];
        }else if (page == 1) {
            [self clickedTypeButton:self.recommendBtn];
        }else if (page == 2) {
            [self clickedTypeButton:self.followBtn];
        }
    }
}

-(void)startRefreshHomeNews {
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMRecommendViewController class]]) {
            LMRecommendViewController* recommendVC = (LMRecommendViewController* )vc;
            if (recommendVC.homeType == self.currentType) {
                [recommendVC startRefreshRecommendData];
                break;
            }
        }
    }
}

-(void)didStartLoginOut {
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"clickedTabBarRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userDidLoginOut" object:nil];
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
