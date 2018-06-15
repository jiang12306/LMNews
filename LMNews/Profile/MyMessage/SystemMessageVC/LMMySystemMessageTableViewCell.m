//
//  LMMySystemMessageTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/23.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMySystemMessageTableViewCell.h"

@implementation LMMySystemMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupDetailView];
    }
    return self;
}

-(void)setupDetailView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, screenWidth - 10 * 2, 20)];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.titleLab belowSubview:self.lineView];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height - 25, screenWidth - 10 * 2, 15)];
        self.timeLab.numberOfLines = 0;
        self.timeLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.timeLab.font = [UIFont systemFontOfSize:14];
        [self.contentView insertSubview:self.timeLab belowSubview:self.lineView];
    }
}

-(void)setupMessageContentWithModel:(LMMySystemMessageModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.titleLab.text = model.title;
    if (model.isRead) {
        self.titleLab.font = [UIFont systemFontOfSize:16];
    }else {
        self.titleLab.font = [UIFont boldSystemFontOfSize:16];
    }
    self.titleLab.frame = CGRectMake(10, 10, screenWidth - 10 * 2, model.titleHeight);
    
    self.timeLab.text = model.time;
    self.timeLab.frame = CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.titleLab.frame.size.width, 15);
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
