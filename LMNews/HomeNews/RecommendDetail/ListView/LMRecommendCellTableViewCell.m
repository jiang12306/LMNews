//
//  LMRecommendCellTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendCellTableViewCell.h"

@implementation LMRecommendCellTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCellDetailViews];
        
//        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

-(void)setupCellDetailViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 85, 20)];
        self.timeLab.textAlignment = NSTextAlignmentCenter;
        self.timeLab.textColor = [UIColor colorWithRed:130/255.f green:130/255.f blue:130/255.f alpha:1];
        self.timeLab.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.timeLab];
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(self.timeLab.frame.origin.x + self.timeLab.frame.size.width + 10, 10, screenWidth - 10 * 2 - self.timeLab.frame.origin.x - self.timeLab.frame.size.width, 20)];
        self.titleLab.textAlignment = NSTextAlignmentLeft;
        self.titleLab.textColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1];
        self.titleLab.font = [UIFont systemFontOfSize:16];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLab];
    }
}

-(void)setupTitleString:(NSString* )titleStr timeString:(NSString* )timeStr {
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.timeLab.text = timeStr;
    
    self.titleLab.text = titleStr;
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
