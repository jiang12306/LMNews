//
//  LMProfileTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMProfileTableViewCell.h"

@implementation LMProfileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTitleLabel];
    }
    return self;
}

-(void)setupTitleLabel {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 25, 25)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFit;
        self.coverIV.clipsToBounds = YES;
        [self.contentView insertSubview:self.coverIV belowSubview:self.lineView];
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 10, 0, 200, 50)];
        self.titleLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.titleLab belowSubview:self.lineView];
    }
    if (!self.dotLab) {
        self.dotLab = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 10 * 4, 20, 10, 10)];
        self.dotLab.backgroundColor = [UIColor colorWithHex:themeOrangeString];
        self.dotLab.layer.cornerRadius = 5;
        self.dotLab.layer.masksToBounds = YES;
        [self.contentView insertSubview:self.dotLab belowSubview:self.lineView];
        self.dotLab.hidden = YES;
    }
}

-(void)setupDotLabelHidden:(BOOL )isHidden {
    if (isHidden) {
        self.dotLab.hidden = YES;
    }else {
        self.dotLab.hidden = NO;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
