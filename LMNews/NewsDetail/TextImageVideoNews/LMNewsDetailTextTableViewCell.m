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
    if (!self.textView) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, screenWidth - 10 * 2, 100)];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;
        [self.contentView addSubview:self.textView];
    }
}

-(void)setupTextContent:(LMNewsDetailModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.textView.attributedText = model.text;
    self.textView.frame = CGRectMake(10, 10, screenWidth - 10 * 2, model.titleHeight);
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
