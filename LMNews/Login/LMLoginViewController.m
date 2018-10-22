//
//  LMLoginViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLoginViewController.h"
#import "LMForgetPasswordViewController.h"
#import "LMTool.h"

@interface LMLoginViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* phoneTF;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMLoginViewController

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
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTF.leftView = phoneView;
    [self.scrollView addSubview:self.phoneTF];
    
    UIImageView* pwdIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    pwdIV.image = [UIImage imageNamed:@"register_Password"];
    
    UIView* pwdView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labHeight, labHeight)];
    [pwdView addSubview:pwdIV];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(self.phoneTF.frame.origin.x, self.phoneTF.frame.origin.y + self.phoneTF.frame.size.height + spaceY, self.phoneTF.frame.size.width, self.phoneTF.frame.size.height)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.borderWidth = 1;
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.pwdTF.keyboardType = UIKeyboardTypeEmailAddress;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
    self.pwdTF.leftView = pwdView;
    self.pwdTF.secureTextEntry = YES;
    self.pwdTF.placeholder = @"请输入密码";
    [self.scrollView addSubview:self.pwdTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.pwdTF.frame.origin.y + self.pwdTF.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.sendBtn.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    UIButton* fastLoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.sendBtn.frame.origin.y + self.sendBtn.frame.size.height + spaceY, 100, 20)];
    NSMutableAttributedString* registerStr = [[NSMutableAttributedString alloc]initWithString:@"手机验证码登录" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [fastLoginBtn setAttributedTitle:registerStr forState:UIControlStateNormal];
    [fastLoginBtn addTarget:self action:@selector(clickedFastLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:fastLoginBtn];
    
    UIButton* forgetPwdBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - spaceX - 60, fastLoginBtn.frame.origin.y, 60, 20)];
    NSMutableAttributedString* forgetPwdStr = [[NSMutableAttributedString alloc]initWithString:@"忘记密码" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:14], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [forgetPwdBtn setAttributedTitle:forgetPwdStr forState:UIControlStateNormal];
    [forgetPwdBtn addTarget:self action:@selector(clickedForgetPwdButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:forgetPwdBtn];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

//收键盘
-(void)stopEditing {
    if ([self.phoneTF isFirstResponder]) {
        [self.phoneTF resignFirstResponder];
    }
    if ([self.pwdTF isFirstResponder]) {
        [self.pwdTF resignFirstResponder];
    }
}

//登录
-(void)clickedSendButton:(UIButton* )sender {
    NSString* phoneStr = [self.phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (phoneStr.length == 0) {
        [self showMBProgressHUDWithText:@"手机号不能为空"];
        return;
    }
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"密码不能为空"];
        return;
    }
    
    [self stopEditing];
    
    RegUserLoginReqBuilder* builder = [RegUserLoginReq builder];
    [builder setU:phoneStr];
    [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    RegUserLoginReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMLoginViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:19 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 19) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    [weakSelf hideNetworkLoadingView];
                    
                    RegUserLoginRes* res = [RegUserLoginRes parseFromData:apiRes.body];
                    LoginedRegUser* logUser = res.loginedUser;
                    NSString* tokenStr = logUser.token;
                    if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
                        
                        if (weakSelf.userBlock) {
                            weakSelf.userBlock(logUser);
                        }
                        
                        //绑定设备与用户
                        [LMTool bindDeviceToUser:logUser];
                        
                        //保存登录用户信息
                        [LMTool saveLoginedRegUser:logUser];
                        
                        //返回
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        
                    }
                }else {
                    [weakSelf showMBProgressHUDWithText:@"账号或密码错误"];
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

//注册
-(void)clickedFastLoginButton:(UIButton* )sender {
    [self stopEditing];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//忘记密码
-(void)clickedForgetPwdButton:(UIButton* )sender {
    [self stopEditing];
    
    LMForgetPasswordViewController* forgetVC = [[LMForgetPasswordViewController alloc]init];
    [self.navigationController pushViewController:forgetVC animated:YES];
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
