//
//  LMNewsDetailTextTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailTextTableViewCell.h"
#import "LMRecommendModel.h"

@implementation LMNewsDetailTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextLab];
        
//        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

-(void)setupTextLab {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.textLab) {
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, screenWidth - 10 * 2, 100)];
        self.textLab.font = [UIFont systemFontOfSize:16];
        self.textLab.numberOfLines = 0;
        self.textLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.textLab];
    }
}

-(void)setupTextContent:(LMNewsDetailModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.textLab.attributedText = model.text;
    self.textLab.frame = CGRectMake(10, 10, screenWidth - 10 * 2, model.titleHeight);
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
