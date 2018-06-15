//
//  LMCommentView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMCommentView.h"
#import "LMTool.h"

@implementation LMCommentView

-(instancetype)initWithFrame:(CGRect)frame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat toolBarHeight = 44;
    CGFloat btnHeight = toolBarHeight - 10;
    if ([LMTool isIPhoneX]) {
        toolBarHeight += 40;
        btnHeight = toolBarHeight - 40;
    }
    self = [super initWithFrame:CGRectMake(0, screenSize.height - toolBarHeight, screenSize.width, toolBarHeight)];
    if (self) {
        if (!self.shareBtn) {
            self.shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenSize.width - 10 - btnHeight, 5, btnHeight, btnHeight)];
            [self.shareBtn addTarget:self action:@selector(clickedShareButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.shareBtn setImage:[UIImage imageNamed:@"commentShare"] forState:UIControlStateNormal];
            [self addSubview:self.shareBtn];
        }
        if (!self.collectBtn) {
            self.collectBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenSize.width - 10 * 2 - btnHeight * 2, 5, btnHeight, btnHeight)];
            [self.collectBtn addTarget:self action:@selector(clickedCollectButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.collectBtn setImage:[UIImage imageNamed:@"commentCollect"] forState:UIControlStateNormal];
            [self.collectBtn setImage:[UIImage imageNamed:@"commentCollect_Selected"] forState:UIControlStateSelected];
            [self addSubview:self.collectBtn];
        }
        if (!self.commentNumBtn) {
            self.commentNumBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenSize.width - 10 * 3 - btnHeight * 3, 5, btnHeight, btnHeight)];
            [self.commentNumBtn addTarget:self action:@selector(clickedCommentNumButton:) forControlEvents:UIControlEventTouchUpInside];
            self.commentNumBtn.selected = NO;
            [self.commentNumBtn setImage:[UIImage imageNamed:@"commentCount"] forState:UIControlStateNormal];
            [self addSubview:self.commentNumBtn];
        }
        if (!self.commentNumLab) {
            CGRect numLabRect = CGRectMake(17, 0, 20, 12);
            if ([LMTool isIPhoneX]) {
                numLabRect = CGRectMake(25, 5, 20, 12);
            }
            self.commentNumLab = [[UILabel alloc]initWithFrame:numLabRect];
            self.commentNumLab.layer.cornerRadius = 5;
            self.commentNumLab.layer.masksToBounds = YES;
            self.commentNumLab.backgroundColor = [UIColor colorWithHex:themeOrangeString];
            self.commentNumLab.textColor = [UIColor whiteColor];
            self.commentNumLab.textAlignment = NSTextAlignmentCenter;
            self.commentNumLab.font = [UIFont systemFontOfSize:8];
            [self.commentNumBtn addSubview:self.commentNumLab];
        }
        if (!self.startInputBtn) {
            self.startInputBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, screenSize.width - 10 * 5 - btnHeight * 3, btnHeight)];
            self.startInputBtn.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
            self.startInputBtn.layer.borderColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1].CGColor;
            self.startInputBtn.layer.borderWidth = .5;
            [self.startInputBtn addTarget:self action:@selector(clickedStartInputBtnButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.startInputBtn setTitle:@"说点什么吧..." forState:UIControlStateNormal];
            [self.startInputBtn setTitleColor:[UIColor colorWithHex:@"#afafaf"] forState:UIControlStateNormal];
            [self addSubview:self.startInputBtn];
        }
    }
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor colorWithHex:@"#afafaf"].CGColor;
    self.layer.borderWidth = .5;
    return self;
}

-(void)clickedShareButton:(UIButton* )sender {
    if (self.shareBlock) {
        self.shareBlock(YES);
    }
}

-(void)clickedCollectButton:(UIButton* )sender {
    if (self.collectBlock) {
        self.collectBlock(YES);
    }
}

-(void)clickedCommentNumButton:(UIButton* )sender {
    if (self.numBlock) {
        if (sender.selected == YES) {
            self.numBlock(NO);
            sender.selected = NO;
        }else {
            self.numBlock(YES);
            sender.selected = YES;
        }
    }
}

-(void)clickedStartInputBtnButton:(UIButton* )sender {
    if (self.commentBlock) {
        self.commentBlock(YES);
    }
}

-(void)setupCollectedState:(BOOL)isCollect {
    if (isCollect) {
        self.collectBtn.selected = YES;
    }else {
        self.collectBtn.selected = NO;
    }
}

-(void)setupCommentCount:(NSInteger)commentCount {
    self.commentNumLab.hidden = NO;
    if (commentCount <= 0) {
        self.commentNumLab.hidden = YES;
    }
    NSString* str = [NSString stringWithFormat:@"%ld", commentCount];
    if (commentCount > 1000) {
        str = @"999+";
    }
    self.commentNumLab.text = str;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
