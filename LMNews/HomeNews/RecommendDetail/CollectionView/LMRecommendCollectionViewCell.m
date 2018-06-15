//
//  LMRecommendCollectionViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendCollectionViewCell.h"

@implementation LMRecommendCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.contentIV) {
        self.contentIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30)];
        self.contentIV.layer.cornerRadius = 10;
        self.contentIV.layer.masksToBounds = YES;
        self.contentIV.contentMode = UIViewContentModeScaleAspectFill;
        self.contentIV.clipsToBounds = YES;
        [self.contentView addSubview:self.contentIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 20)];
        self.nameLab.textColor = [UIColor blackColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.font = [UIFont systemFontOfSize:14];
        self.nameLab.numberOfLines = 3;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    self.contentIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 60);
    if (self.nameLab.text) {
        self.nameLab.frame = CGRectMake(0, self.frame.size.height - 60, self.frame.size.width, 60);
    }else {
        self.nameLab.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
    }
    
}

@end
