//
//  LMBaseViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"
#import "MBProgressHUD.h"
#import <UMAnalytics/MobClick.h>

@interface LMBaseViewController ()

//网络加载视图
@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, strong) UIImageView* loadingIV;
@property (nonatomic, strong) UILabel* loadingLab;

//刷新按钮
@property (nonatomic, strong) UIButton* selfReloadBtn;

//无数据 提示label
@property (nonatomic, strong) UILabel* emptyLabel;

@end

@implementation LMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (@available(ios 11.0, *)) {
        
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //友盟统计
    NSString* pageName = NSStringFromClass([self class]);
    [MobClick beginLogPageView:pageName];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //友盟统计
    NSString* pageName = NSStringFromClass([self class]);
    [MobClick endLogPageView:pageName];
}

//显示 网络加载
-(void)showNetworkLoadingView {
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - 120)/2, 70, 70)];
        self.loadingView.backgroundColor = [UIColor colorWithRed:40.f/255 green:40.f/255 blue:40.f/255 alpha:0.6];
        self.loadingView.layer.cornerRadius = 5;
        self.loadingView.layer.masksToBounds = YES;
        
        self.loadingIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
        NSMutableArray* imgArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 7; i ++) {
            NSString* imgStr = [NSString stringWithFormat:@"loading%ld", (long)i];
            UIImage* img = [UIImage imageNamed:imgStr];
            [imgArr addObject:img];
        }
        self.loadingIV.animationImages = imgArr;
        self.loadingIV.animationDuration = 1;
        [self.loadingView addSubview:self.loadingIV];
        
        self.loadingLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.loadingView.frame.size.height - 25, self.loadingView.frame.size.height, 20)];
        self.loadingLab.textColor = [UIColor whiteColor];
        self.loadingLab.textAlignment = NSTextAlignmentCenter;
        self.loadingLab.font = [UIFont systemFontOfSize:14];
        self.loadingLab.text = @"加载中···";
        [self.loadingView addSubview:self.loadingLab];
        
        [self.view insertSubview:self.loadingView atIndex:999];
        self.loadingView.hidden = YES;
    }
    //隐藏 刷新 按钮
    [self hideReloadButton];
    [self hideEmptyLabel];
    
    self.loadingView.hidden = NO;
    [self.loadingIV startAnimating];
    [self.view bringSubviewToFront:self.loadingView];
}

//隐藏 网络加载
-(void)hideNetworkLoadingView {
    [self.loadingIV stopAnimating];
    self.loadingView.hidden = YES;
}

//MBProgressHUD
-(void)showMBProgressHUDWithText:(NSString *)hudText {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hudText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

//显示 刷新按钮
-(void)showReloadButton {
    if (!self.selfReloadBtn) {
        self.selfReloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.selfReloadBtn.center = self.view.center;
        UIImage* img = [UIImage imageNamed:@"defaultRefresh"];
        UIImage* tintImg = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.selfReloadBtn setTintColor:[UIColor grayColor]];
        [self.selfReloadBtn setImage:tintImg forState:UIControlStateNormal];
        [self.selfReloadBtn addTarget:self action:@selector(clickedSelfReloadButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.selfReloadBtn];
        self.selfReloadBtn.hidden = YES;
    }
    //隐藏 空空如也 提示
    [self hideEmptyLabel];
    [self hideNetworkLoadingView];
    
    self.selfReloadBtn.hidden = NO;
    [self.view bringSubviewToFront:self.selfReloadBtn];
}

//隐藏 刷新按钮
-(void)hideReloadButton {
    self.selfReloadBtn.hidden = YES;
}

//点击 刷新按钮
-(void)clickedSelfReloadButton:(UIButton* )sender {
    [self hideReloadButton];
    
}

//显示 无数据
-(void)showEmptyLabelWithText:(NSString* )emptyText {
    if (!self.emptyLabel) {
        self.emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        self.emptyLabel.center = self.view.center;
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.textColor = [UIColor grayColor];
        self.emptyLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:self.emptyLabel];
        self.emptyLabel.hidden = YES;
    }
    NSString* str = @"空空如也";
    if (emptyText != nil) {
        str = emptyText;
    }
    //隐藏 刷新 按钮
    [self hideReloadButton];
    [self hideNetworkLoadingView];
    
    self.emptyLabel.text = str;
    self.emptyLabel.hidden = NO;
    [self.view bringSubviewToFront:self.emptyLabel];
}

//隐藏 无数据
-(void)hideEmptyLabel {
    self.emptyLabel.hidden = YES;
}

-(void)dealloc {
    NSLog(@"---------dealloc---------");
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
