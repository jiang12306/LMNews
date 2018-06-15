//
//  LMFastLoginViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/21.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMFastLoginViewController.h"
#import "LMLoginViewController.h"
#import "LMTool.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface LMFastLoginViewController () <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth* qqAuth;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* codeTF;
@property (nonatomic, strong) UIButton* codeBtn;
@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, strong) UIButton* switchBtn;/**<切换至密码登录*/
@property (nonatomic, strong) UIButton* qqBtn;/**<QQ登录*/
@property (nonatomic, strong) UIButton* weChatBtn;/**<WeChat登录*/
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) NSTimer* timer;

@end

@implementation LMFastLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"登录";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 20;
    CGFloat labHeight = 40;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UIImageView* phoneIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    phoneIV.image = [UIImage imageNamed:@"register_Avator"];
    
    UIView* phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labHeight, labHeight)];
    [phoneView addSubview:phoneIV];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.phoneTF.placeholder = @"手机号";
    self.phoneTF.backgroundColor = [UIColor whiteColor];
    self.phoneTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.phoneTF.layer.borderWidth = 1;
    self.phoneTF.layer.cornerRadius = 1;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTF.leftView = phoneView;
    [self.scrollView addSubview:self.phoneTF];
    
    self.codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 80, self.phoneTF.frame.origin.y + self.phoneTF.frame.size.height + spaceY, 80, labHeight)];
    self.codeBtn.layer.cornerRadius = 5;
    self.codeBtn.layer.masksToBounds = YES;
    self.codeBtn.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.codeBtn.layer.borderWidth = 1;
    self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn setTitleColor:[UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1] forState:UIControlStateNormal];
    [self.codeBtn addTarget:self action:@selector(clickedCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    self.codeBtn.selected = NO;
    [self.scrollView addSubview:self.codeBtn];
    
    self.codeTF = [[UITextField alloc]initWithFrame:CGRectMake(self.phoneTF.frame.origin.x, self.codeBtn.frame.origin.y, self.view.frame.size.width - self.codeBtn.frame.size.width - spaceX * 3, self.phoneTF.frame.size.height)];
    self.codeTF.backgroundColor = [UIColor whiteColor];
    self.codeTF.layer.borderWidth = 1;
    self.codeTF.layer.cornerRadius = 1;
    self.codeTF.layer.masksToBounds = YES;
    self.codeTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeTF.placeholder = @" 验证码";
    [self.scrollView addSubview:self.codeTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.codeTF.frame.origin.y + self.codeTF.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.sendBtn.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    self.switchBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.switchBtn.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    self.switchBtn.layer.cornerRadius = 5;
    self.switchBtn.layer.masksToBounds = YES;
    [self.switchBtn setTitle:@"账号密码登录" forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(clickedSwitchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.switchBtn];
    
    self.weChatBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, 80, 100)];
    [self.weChatBtn addTarget:self action:@selector(clickedWeChatButton:) forControlEvents:UIControlEventTouchUpInside];
    self.weChatBtn.center = CGPointMake(self.view.frame.size.width / 3, self.view.frame.size.height - 120);
    [self.scrollView addSubview:self.weChatBtn];
    
    UIImageView* weChatIV = [[UIImageView alloc]initWithFrame:CGRectMake(7, 0, 65, 60)];
    weChatIV.image = [UIImage imageNamed:@"weChat"];
    [self.weChatBtn addSubview:weChatIV];
    UILabel* weChatLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 80, 20)];
    weChatLab.font = [UIFont systemFontOfSize:16];
    weChatLab.text = @"微信登录";
    weChatLab.textAlignment = NSTextAlignmentCenter;
    [self.weChatBtn addSubview:weChatLab];
    
    self.qqBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 100)];
    [self.qqBtn addTarget:self action:@selector(clickedQQButton:) forControlEvents:UIControlEventTouchUpInside];
    self.qqBtn.center = CGPointMake(self.view.frame.size.width * 2 / 3, self.weChatBtn.center.y);
    [self.scrollView addSubview:self.qqBtn];
    
    UIImageView* qqIV = [[UIImageView alloc]initWithFrame:CGRectMake(13, 0, 53, 60)];
    qqIV.image = [UIImage imageNamed:@"qq"];
    [self.qqBtn addSubview:qqIV];
    UILabel* qqLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 80, 20)];
    qqLab.font = [UIFont systemFontOfSize:16];
    qqLab.text = @"QQ登录";
    qqLab.textAlignment = NSTextAlignmentCenter;
    [self.qqBtn addSubview:qqLab];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //微信 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatDidLogin:) name:weChatLoginNotifyName object:nil];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

//收键盘
-(void)stopEditing {
    if ([self.phoneTF isFirstResponder]) {
        [self.phoneTF resignFirstResponder];
    }
    if ([self.codeTF isFirstResponder]) {
        [self.codeTF resignFirstResponder];
    }
}

//
-(void)setupTimer {
    if (!self.timer) {
        self.count = 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCount) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

//
-(void)startCount {
    self.count --;
    if (self.count <= 0) {
        [self.timer setFireDate:[NSDate distantFuture]];
        self.count = 60;
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.codeBtn.selected = NO;
        return;
    }
    [self.codeBtn setTitle:[NSString stringWithFormat:@"剩余%lds", self.count] forState:UIControlStateNormal];
}

//获取验证码
-(void)clickedCodeButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pattern = @"^1+[34578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneStr];
    if (!isMatch) {
        [self showMBProgressHUDWithText:@"手机号码格式不正确"];
        return;
    }
    
    [self stopEditing];
    
    if (self.codeBtn.selected == NO) {
        
        VerifyCodeReqBuilder* builder = [VerifyCodeReq builder];
        [builder setPhoneNum:phoneStr];
        [builder setSmsType:SmsTypeSmsReg];
        VerifyCodeReq* req = [builder build];
        NSData* reqData = [req data];
        
        [self showNetworkLoadingView];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:13 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
                if (apiRes.cmd == 13) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        //初始化timer
                        [self setupTimer];
                        
                        self.codeBtn.selected = YES;
                        [self.timer setFireDate:[NSDate distantPast]];
                        
                    }else if (err == ErrCodeErrCountlimit) {//验证码次数超过上限
                        [self showMBProgressHUDWithText:@"验证码次数超过上限"];
                    }else if (err == ErrCodeErrTimelimit) {//验证码有效期内
                        
                    }else {
                        [self showMBProgressHUDWithText:@"获取验证码失败"];
                    }
                }
                
            } @catch (NSException *exception) {
                [self showMBProgressHUDWithText:NetworkFailedError];
            } @finally {
                
            }
            [self hideNetworkLoadingView];
        } failureBlock:^(NSError *failureError) {
            [self showMBProgressHUDWithText:@"获取验证码失败"];
            [self hideNetworkLoadingView];
        }];
    }
}

//登录
-(void)clickedSendButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* codeStr = [self.codeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (phoneStr.length == 0) {
        [self showMBProgressHUDWithText:@"手机号不能为空"];
        return;
    }
    if (codeStr.length == 0) {
        [self showMBProgressHUDWithText:@"密码不能为空"];
        return;
    }
    
    [self stopEditing];
    
    CheckVerifyCodeReqBuilder* builder = [CheckVerifyCodeReq builder];
    [builder setPhoneNum:phoneStr];
    [builder setVcode:codeStr];
    [builder setSmsType:SmsTypeSmsReg];
    CheckVerifyCodeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:14 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 14) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [self hideNetworkLoadingView];
                    
                    CheckVerifyCodeRes* res = [CheckVerifyCodeRes parseFromData:apiRes.body];
                    LoginedRegUser* logUser = res.loginedUser;
                    NSString* tokenStr = logUser.token;
                    if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                        
                        //block回调
                        if (self.userBlock) {
                            self.userBlock(logUser);
                        }
                        
                        //绑定设备与用户
                        [LMTool bindDeviceToUser:logUser];
                        
                        //保存登录用户信息
                        [LMTool saveLoginedRegUser:logUser];
                        
                        //返回
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                }else {
                    [self showMBProgressHUDWithText:@"账号或密码错误"];
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

//
-(void)clickedSwitchButton:(UIButton* )sender {
    [self stopEditing];
    
    LMLoginViewController* loginVC = [[LMLoginViewController alloc]init];
    loginVC.userBlock = ^(LoginedRegUser *loginUser) {
        if (loginUser != nil) {
            if (self.userBlock) {
                self.userBlock(loginUser);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [self.navigationController pushViewController:loginVC animated:YES];
}

//点击 微信 登录
-(void)clickedWeChatButton:(UIButton* )sender {
    [self stopEditing];
    
    //
    SendAuthReq* request = [[SendAuthReq alloc]init];
    request.state = weChatLoginState;
    request.scope = @"snsapi_userinfo";
    [WXApi sendReq:request];
}

//微信 登录成功
-(void)weChatDidLogin:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        [self showMBProgressHUDWithText:@"登录失败"];
        return;
    }
    NSString* codeStr = [dic objectForKey:weChatLoginKey];
    if (codeStr != nil && ![codeStr isKindOfClass:[NSNull class]] && codeStr.length > 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setWx:@"1"];
        RegUser* regUser = [userBuilder build];
        [self uploadThirdLoginWithUser:regUser codeStr:codeStr];
    }else {
        [self showMBProgressHUDWithText:@"登录失败"];
    }
}

//点击 微信 登录
-(void)clickedQQButton:(UIButton* )sender {
    [self stopEditing];
    
    //
    self.qqAuth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
    NSArray* permissionArr = @[@"get_user_info", @"get_simple_userinfo"];
    [self.qqAuth authorize:permissionArr inSafari:NO];
    
}

#pragma mark -TencentSessionDelegate
-(void)tencentDidLogin {
    if (self.qqAuth.accessToken && [self.qqAuth.accessToken length] != 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setQq:@"2"];
        RegUser* regUser = [userBuilder build];
        [self uploadThirdLoginWithUser:regUser codeStr:self.qqAuth.accessToken];
        
        //取用户信息 屏蔽  后端取
//        [self.qqAuth getUserInfo]
    }else {
        [self showMBProgressHUDWithText:@"登录失败"];
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled {
    [self showMBProgressHUDWithText:@"登录失败"];
}

-(void)tencentDidNotNetWork {
    [self showMBProgressHUDWithText:@"登录失败"];
}

-(void)getUserInfoResponse:(APIResponse *)response {
    
}


//third login
-(void)uploadThirdLoginWithUser:(RegUser* )user codeStr:(NSString* )codeStr {
    ThirdRegUserLoginReqBuilder* builder = [ThirdRegUserLoginReq builder];
    [builder setUser:user];
    [builder setCode:codeStr];
    ThirdRegUserLoginReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMFastLoginViewController* weakSelf = self;
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:24 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 24) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [weakSelf hideNetworkLoadingView];
                    
                    ThirdRegUserLoginRes* res = [ThirdRegUserLoginRes parseFromData:apiRes.body];
                    LoginedRegUser* logUser = res.loginedUser;
                    NSString* tokenStr = logUser.token;
                    if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                        
                        //block回调
                        if (weakSelf.userBlock) {
                            weakSelf.userBlock(logUser);
                        }
                        
                        //绑定设备与用户
                        [LMTool bindDeviceToUser:logUser];
                        
                        //保存登录用户信息
                        [LMTool saveLoginedRegUser:logUser];
                        
                        //返回
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        
                    }else {
                        [weakSelf showMBProgressHUDWithText:@"出错啦^_^"];
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:@"出错啦^_^"];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:NetworkFailedError];
        [weakSelf hideNetworkLoadingView];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatLoginNotifyName object:nil];
    
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
