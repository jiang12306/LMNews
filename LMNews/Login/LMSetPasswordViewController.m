//
//  LMSetPasswordViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSetPasswordViewController.h"
#import "LMLoginViewController.h"
#import "LMTool.h"

@interface LMSetPasswordViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UITextField* conformTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"设置密码";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 20;
    CGFloat labHeight = 40;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.borderWidth = 1;
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwdTF.secureTextEntry = YES;
    self.pwdTF.placeholder = @"输入新密码";
    self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
    UIView* pwdLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, labHeight)];
    self.pwdTF.leftView = pwdLeftView;
    [self.scrollView addSubview:self.pwdTF];
    
    self.conformTF = [[UITextField alloc]initWithFrame:CGRectMake(self.pwdTF.frame.origin.x, self.pwdTF.frame.origin.y + self.pwdTF.frame.size.height + spaceY, self.pwdTF.frame.size.width, self.pwdTF.frame.size.height)];
    self.conformTF.backgroundColor = [UIColor whiteColor];
    self.conformTF.layer.borderWidth = 1;
    self.conformTF.layer.cornerRadius = 5;
    self.conformTF.layer.masksToBounds = YES;
    self.conformTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.conformTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.conformTF.secureTextEntry = YES;
    self.conformTF.placeholder = @"确认新密码";
    self.conformTF.leftViewMode = UITextFieldViewModeAlways;
    UIView* conformLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, labHeight)];
    self.conformTF.leftView = conformLeftView;
    [self.scrollView addSubview:self.conformTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.conformTF.frame.origin.y + self.conformTF.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.sendBtn.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
}

//
-(void)clickedSendButton:(UIButton* )sender {
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr2 = [self.conformTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入密码"];
        return;
    }
    if (pwdStr2.length == 0) {
        [self showMBProgressHUDWithText:@"请确认密码"];
        return;
    }
    if (![pwdStr isEqualToString:pwdStr2]) {
        [self showMBProgressHUDWithText:@"密码不一致"];
        return;
    }
    
    [self showNetworkLoadingView];
    
    PhoneNumRegAndResetPwdReqBuilder* builder = [PhoneNumRegAndResetPwdReq builder];
    [builder setReqType:1];//只要是验证码入口修改密码，type值0和1是一样的
    [builder setPhoneNum:self.phoneStr];
    [builder setVcode:self.verifyStr];
    [builder setMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    PhoneNumRegAndResetPwdReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMSetPasswordViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:17 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 17) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    [weakSelf hideNetworkLoadingView];
                    
                    PhoneNumRegAndResetPwdRes* res = [PhoneNumRegAndResetPwdRes parseFromData:apiRes.body];
                    LoginedRegUser* logUser = res.loginedUser;
                    
                    //保存登录用户信息
                    [LMTool saveLoginedRegUser:logUser];
                    
                    if (logUser != nil) {
                        BOOL isContain = NO;
                        UIViewController* loginVC = nil;
                        for (UIViewController* vc in self.navigationController.viewControllers) {
                            if ([vc isKindOfClass:[LMLoginViewController class]]) {
                                isContain = YES;
                                loginVC = vc;
                                break;
                            }
                        }
                        if (isContain) {//返回到登录界面
                            [self.navigationController popToViewController:loginVC animated:YES];
                        }else {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }
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
