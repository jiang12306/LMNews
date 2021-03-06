//
//  LMShareView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMShareView.h"
#import "LMTool.h"

@interface LMShareView ()

@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIButton* cancelBtn;

@end

@implementation LMShareView

CGFloat btnWidth = 60;

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor clearColor]colorWithAlphaComponent:0];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];
        self.hidden = YES;
        
        CGFloat totalHeight = 50 + btnWidth + 10 * 3 + 50;
        if ([LMTool isIPhoneX]) {
            totalHeight += 40;
        }
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height - totalHeight, screenRect.size.width, totalHeight)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.layer.borderWidth = 0.5;
        self.bgView.layer.borderColor = [UIColor colorWithRed:165/255.f green:165/255.f blue:165/255.f alpha:1].CGColor;
        [self addSubview:self.bgView];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, self.frame.size.width, btnWidth + 30)];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self.bgView addSubview:self.scrollView];
        
        NSArray* imageArr = @[@"weChat", @"weChat_Moment", @"qq", @"qq_Zone", @"share_Link"];
        NSArray* titleArr = @[@"微信好友", @"朋友圈", @"QQ好友", @"QQ空间", @"拷贝链接"];
        for (NSInteger i = 0; i < titleArr.count; i ++) {
            
            UIView* view = [[UIView alloc]initWithFrame:CGRectMake(20 + (btnWidth + 20) * i, 0, btnWidth, btnWidth + 30)];
            [self.scrollView addSubview:view];
            
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth)];
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.tag = i;
            [btn addTarget:self action:@selector(clickedItemButton:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
            
            UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
            iv.backgroundColor = [UIColor clearColor];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            iv.image = [UIImage imageNamed:imageArr[i]];
            [btn addSubview:iv];
            
            UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, btnWidth, btnWidth, 30)];
            lab.font = [UIFont systemFontOfSize:12];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = titleArr[i];
            [view addSubview:lab];
        }
        self.scrollView.contentSize = CGSizeMake((btnWidth + 20) * titleArr.count + 20, 0);
        
        self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height + 40, self.bgView.frame.size.width, 50)];
        self.cancelBtn.backgroundColor = [UIColor whiteColor];
        self.cancelBtn.layer.borderWidth = 0.5;
        self.cancelBtn.layer.borderColor = [UIColor colorWithRed:165/255.f green:165/255.f blue:165/255.f alpha:1].CGColor;
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:self.cancelBtn];
    }
    return self;
}

-(void)clickedItemButton:(UIButton* )sender {
    NSInteger tag = sender.tag;
    LMShareViewType type = LMShareViewTypeWeChat;
    if (tag == 0) {
        type = LMShareViewTypeWeChat;
    }else if (tag == 1) {
        type = LMShareViewTypeWeChatMoment;
    }else if (tag == 2) {
        type = LMShareViewTypeQQ;
    }else if (tag == 3) {
        type = LMShareViewTypeQQZone;
    }else if (tag == 4) {
        type = LMShareViewTypeCopyLink;
    }
    if (self.shareBlock) {
        self.shareBlock(type);
    }
    [self startHide];
}

-(void)clickedCancelButton:(UIButton* )sender {
    [self startHide];
}

-(void)startShow {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.2 animations:^{
        self.hidden = NO;
        self.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    }];
}

-(void)startHide {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    UIView* touchView = touch.view;
    if (touchView != self.bgView) {
        [self startHide];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
