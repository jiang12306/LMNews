//
//  LMMySystemMessageDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/24.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMySystemMessageDetailViewController.h"

@interface LMMySystemMessageDetailViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* contentLab;

@end

@implementation LMMySystemMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息详情";
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10 * 2, 0)];
    self.titleLab.font = [UIFont boldSystemFontOfSize:16];
    self.titleLab.numberOfLines = 0;
    self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
    [self.scrollView addSubview:self.titleLab];
    
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10 * 2, 0)];
    self.timeLab.font = [UIFont systemFontOfSize:14];
    self.timeLab.textColor = [UIColor grayColor];
    [self.scrollView addSubview:self.timeLab];
    
    self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10 * 2, 0)];
    self.contentLab.font = [UIFont systemFontOfSize:16];
    self.contentLab.numberOfLines = 0;
    self.contentLab.lineBreakMode = NSLineBreakByCharWrapping;
    [self.scrollView addSubview:self.contentLab];
    
    //
    [self loadSystemMessageDetailData];
}

-(void)loadSystemMessageDetailData {
    SysMsgReqBuilder* builder = [SysMsgReq builder];
    [builder setId:(UInt32 )self.msgId];
    SysMsgReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:22 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            QiWenApiRes* apiRes = [QiWenApiRes parseFromData:successData];
            if (apiRes.cmd == 22) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SysMsgRes* res = [SysMsgRes parseFromData:apiRes.body];
                    
                    SysMsg* msg = res.sysmsg;
                    CGFloat titleHeight = [self caculateSystemMessageHeightWithFont:[UIFont boldSystemFontOfSize:16] text:msg.title];
                    self.titleLab.frame = CGRectMake(10, 10, self.view.frame.size.width - 10 * 2, titleHeight);
                    self.titleLab.text = msg.title;
                    
                    self.timeLab.frame = CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.view.frame.size.width - 10 * 2, 15);
                    self.timeLab.text = msg.sT;
                    
                    CGFloat contentHeight = [self caculateSystemMessageHeightWithFont:[UIFont systemFontOfSize:16] text:msg.content];
                    self.contentLab.frame = CGRectMake(10, self.timeLab.frame.origin.y + self.timeLab.frame.size.height + 10, self.view.frame.size.width - 10 * 2, contentHeight);
                    self.contentLab.text = msg.content;
                    
                    self.scrollView.contentSize = CGSizeMake(0, self.contentLab.frame.origin.y + self.contentLab.frame.size.height + 10);
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

-(CGFloat )caculateSystemMessageHeightWithFont:(UIFont* )font text:(NSString* )text {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectZero];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    lab.font = font;
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(self.view.frame.size.width - 10 * 2, CGFLOAT_MAX)];
    return labSize.height;
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
