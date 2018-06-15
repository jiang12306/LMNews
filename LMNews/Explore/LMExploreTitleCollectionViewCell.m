//
//  LMExploreTitleCollectionViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMExploreTitleCollectionViewCell.h"

@implementation LMExploreTitleCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.nameLab.textColor = [UIColor blackColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.lineView) {
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        self.lineView.backgroundColor = [UIColor colorWithHex:themeOrangeString];
        [self.contentView addSubview:self.lineView];
        self.lineView.hidden = YES;
    }
}

-(void)layoutSubviews {
    if (self.nameLab.text) {
        self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.lineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    }
}

-(void)setupSelected:(BOOL)isCurrent {
    if (isCurrent) {
        self.nameLab.font = [UIFont boldSystemFontOfSize:20];
        self.lineView.hidden = NO;
    }else {
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.lineView.hidden = YES;
    }
}

@end
