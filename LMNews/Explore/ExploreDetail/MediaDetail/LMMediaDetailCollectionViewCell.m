//
//  LMMediaDetailCollectionViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/18.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMediaDetailCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMMediaDetailCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.mediaIV) {
        self.mediaIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.mediaIV.userInteractionEnabled = YES;
        self.mediaIV.layer.cornerRadius = 5;
        self.mediaIV.layer.masksToBounds = YES;
        self.mediaIV.contentMode = UIViewContentModeScaleAspectFill;
        self.mediaIV.clipsToBounds = YES;
        [self.contentView addSubview:self.mediaIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.nameLab.textColor = [UIColor whiteColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.subBtn) {
        self.subBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        self.subBtn.backgroundColor = [UIColor colorWithHex:subOrangeString];
        self.subBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.subBtn addTarget:self action:@selector(clickedSubButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.subBtn];
    }
}

-(void)layoutSubviews {
    if (self.nameLab.text) {
        self.mediaIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.nameLab.frame = CGRectMake(0, 40, self.frame.size.width, 20);
        self.subBtn.frame = CGRectMake(10, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 10, 80, 20);
    }
}

-(void)clickedSubButton:(UIButton* )sender {
    if (self.block) {
        self.block(YES, self);
    }
}

-(void)setupSubscriptionWithSource:(LMSource *)source {
    NSString* imgStr = source.url;
    [self.mediaIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    self.nameLab.text = source.sourceName;
    
    BOOL isSub = NO;
    if (source.isSub) {
        isSub = YES;
    }
    if (isSub) {
        [self.subBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    }else {
        [self.subBtn setTitle:@"+关注" forState:UIControlStateNormal];
    }
}

@end
