//
//  LMHomeRightBarButtonItemView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/31.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMHomeRightBarButtonItemView.h"

@implementation LMHomeRightBarButtonItemView

static NSString* messageAlertNotificationName = @"messageAlertNotificationName";
static NSString* unreadMsgKey = @"messageAlertKeyName";

+(void)setupNewMessage:(BOOL)hasMsg {
    if (hasMsg) {
        NSDictionary* dic = @{@"msg":@1};
        [[NSNotificationCenter defaultCenter]postNotificationName:messageAlertNotificationName object:nil userInfo:dic];
    }else {
        [[NSNotificationCenter defaultCenter]postNotificationName:messageAlertNotificationName object:nil userInfo:nil];
    }
}

+(BOOL)hasUnreadMessage {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:unreadMsgKey];
}

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(0, 0, 30, 30);
    self = [super initWithFrame:rect];
    if (self) {
        self.bgBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        [self.bgBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgBtn];
        
        self.alertIV = [[UIImageView alloc]initWithFrame:CGRectMake(2.5, 2.5, rect.size.width - 5, rect.size.height - 5)];
        self.alertIV.image = [UIImage imageNamed:@"messageAlert"];
        [self insertSubview:self.alertIV aboveSubview:self.bgBtn];
        
        self.dotLab = [[UILabel alloc]initWithFrame:CGRectMake(rect.size.width - 12, 0, 10, 10)];
        self.dotLab.backgroundColor = [UIColor colorWithHex:themeOrangeString];
        self.dotLab.layer.cornerRadius = 5;
        self.dotLab.layer.masksToBounds = YES;
        [self insertSubview:self.dotLab aboveSubview:self.alertIV];
        self.dotLab.hidden = YES;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessageAlert:) name:messageAlertNotificationName object:nil];
    }
    return self;
}

-(void)clickedRightBarButtonItem:(UIButton* )sender {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}

-(void)didReceiveMessageAlert:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic != nil && ![dic isKindOfClass:[NSNull class]] && dic.count > 0) {
        self.dotLab.hidden = NO;
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:unreadMsgKey];
        [userDefaults synchronize];
    }else {
        self.dotLab.hidden = YES;
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:unreadMsgKey];
        [userDefaults synchronize];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:messageAlertNotificationName object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
