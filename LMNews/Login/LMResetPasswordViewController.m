//
//  LMResetPasswordViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMResetPasswordViewController.h"
#import "LMTool.h"

@interface LMResetPasswordViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UITextField* oldPwdTF;
@property (nonatomic, strong) UITextField* pwdTF;
@property (nonatomic, strong) UITextField* conformTF;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"修改密码";
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 20;
    CGFloat labHeight = 40;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.oldPwdTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, spaceY, self.view.frame.size.width - spaceX * 2, labHeight)];
    self.oldPwdTF.backgroundColor = [UIColor whiteColor];
    self.oldPwdTF.layer.cornerRadius = 1;
    self.oldPwdTF.layer.masksToBounds = YES;
    self.oldPwdTF.layer.borderWidth = 1;
    self.oldPwdTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.oldPwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.oldPwdTF.secureTextEntry = YES;
    self.oldPwdTF.placeholder = @" 旧密码";
    [self.scrollView addSubview:self.oldPwdTF];
    
    self.pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(spaceX, self.oldPwdTF.frame.origin.y + self.oldPwdTF.frame.size.height + spaceY, self.oldPwdTF.frame.size.width, labHeight)];
    self.pwdTF.backgroundColor = [UIColor whiteColor];
    self.pwdTF.layer.cornerRadius = 5;
    self.pwdTF.layer.masksToBounds = YES;
    self.pwdTF.layer.borderWidth = 1;
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
    self.conformTF.layer.cornerRadius = 5;
    self.conformTF.layer.masksToBounds = YES;
    self.conformTF.layer.borderWidth = 1;
    self.conformTF.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
    self.conformTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.conformTF.secureTextEntry = YES;
    self.conformTF.placeholder = @"确认新密码";
    self.conformTF.leftViewMode = UITextFieldViewModeAlways;
    UIView* conformLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, labHeight)];
    self.conformTF.leftView = conformLeftView;
    [self.scrollView addSubview:self.conformTF];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, self.conformTF.frame.origin.y + self.conformTF.frame.size.height + spaceY, self.view.frame.size.width - spaceX * 2, 40)];
    self.sendBtn.backgroundColor = [UIColor colorWithHex:themeOrangeString];
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendBtn];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self stopEditing];
}

-(void)stopEditing {
    if ([self.oldPwdTF isFirstResponder]) {
        [self.oldPwdTF resignFirstResponder];
    }
    if ([self.pwdTF isFirstResponder]) {
        [self.pwdTF resignFirstResponder];
    }
    if ([self.conformTF isFirstResponder]) {
        [self.conformTF resignFirstResponder];
    }
}

//
-(void)clickedSendButton:(UIButton* )sender {
    NSString* oldPwdStr = [self.oldPwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr = [self.pwdTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* pwdStr2 = [self.conformTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (oldPwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入旧密码"];
        return;
    }
    if (pwdStr.length == 0) {
        [self showMBProgressHUDWithText:@"请输入新密码"];
        return;
    }
    if (pwdStr2.length == 0) {
        [self showMBProgressHUDWithText:@"请确认新密码"];
        return;
    }
    if (![pwdStr isEqualToString:pwdStr2]) {
        [self showMBProgressHUDWithText:@"密码不一致"];
        return;
    }
    
    [self stopEditing];
    
    [self showNetworkLoadingView];
    
    ResetPwdReqBuilder* builder = [ResetPwdReq builder];
    [builder setOldMd5Pwd:[LMTool MD5ForLower32Bate:oldPwdStr]];
    [builder setNewMd5Pwd:[LMTool MD5ForLower32Bate:pwdStr]];
    ResetPwdReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMResetPasswordViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:18 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 18) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                    [weakSelf showMBProgressHUDWithText:@"修改成功"];
                    
                }else {
                    [weakSelf showMBProgressHUDWithText:@"修改失败"];
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
