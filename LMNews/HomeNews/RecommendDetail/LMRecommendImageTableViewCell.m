//
//  LMRecommendImageTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendModel.h"
#import "UIImageView+WebCache.h"

@implementation LMRecommendImageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentViews];
        
//        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)setupContentViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 150, 20)];
        self.timeLab.textAlignment = NSTextAlignmentLeft;
        self.timeLab.textColor = [UIColor colorWithHex:themeOrangeString];
        self.timeLab.font = [UIFont systemFontOfSize:mediaNameFontSize];
        self.timeLab.numberOfLines = 0;
        self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.timeLab];
    }
    if (!self.commentCountLab) {
        self.commentCountLab = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 10 - 40, 10, 40, 20)];
        self.commentCountLab.textAlignment = NSTextAlignmentLeft;
        self.commentCountLab.font = [UIFont systemFontOfSize:mediaNameFontSize];
        self.commentCountLab.numberOfLines = 0;
        self.commentCountLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.commentCountLab];
    }
    if (!self.commentIV) {
        self.commentIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.commentCountLab.frame.origin.x - 20 - 5, 10, 20, 20)];
        self.commentIV.image = [UIImage imageNamed:@"comment_Bubble"];
        [self.contentView addSubview:self.commentIV];
    }
    if (!self.contentIV) {
        self.contentIV = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 10 - contentIVWidth, 10, contentIVWidth, contentIVHeight)];
        self.contentIV.contentMode = UIViewContentModeScaleAspectFill;
        self.contentIV.clipsToBounds = YES;
        [self.contentView addSubview:self.contentIV];
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - contentIVWidth - 10 * 3, 35)];
        self.titleLab.textAlignment = NSTextAlignmentLeft;
        self.titleLab.font = [UIFont systemFontOfSize:titleFontSize];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLab];
    }
    if (!self.detailLab) {
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.titleLab.frame.size.width, 30)];
        self.detailLab.font = [UIFont systemFontOfSize:detailFontSize];
        self.detailLab.textColor = [UIColor colorWithHex:articleDetailString];
        self.detailLab.numberOfLines = 0;
        self.detailLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.detailLab];
    }
    if (!self.mediaNameLab) {
        self.mediaNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, screenWidth - 10 * 2, 15)];
        self.mediaNameLab.font = [UIFont systemFontOfSize:mediaNameFontSize];
        self.mediaNameLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.mediaNameLab.numberOfLines = 0;
        self.mediaNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.mediaNameLab];
    }
}

- (void)setupContentWithModel:(LMRecommendModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.timeLab.hidden = YES;
    self.commentIV.hidden = YES;
    self.commentCountLab.hidden = YES;
    CGFloat startY = 10;
    if (model.showTime) {
        self.timeLab.hidden = NO;
        self.timeLab.text = model.time;
        if (model.commentCountStr != nil && model.commentCountStr.length > 0) {
            self.commentIV.hidden = NO;
            self.commentCountLab.hidden = NO;
            self.commentCountLab.text = model.commentCountStr;
            self.commentCountLab.frame = CGRectMake(screenWidth - 10 - model.commentWidth, 10, model.commentWidth, 20);
            self.commentIV.frame = CGRectMake(self.commentCountLab.frame.origin.x - 20 - 5, 10, 20, 20);
        }
        startY = self.timeLab.frame.origin.y + self.timeLab.frame.size.height + 10;
    }
    
    self.titleLab.text = model.title;
    self.titleLab.frame = CGRectMake(10, startY, screenWidth - contentIVWidth - spaceX * 3, model.titleHeight);
    self.contentIV.frame = CGRectMake(screenWidth - 10 - contentIVWidth, startY, contentIVWidth, contentIVHeight);
    
    if (model.brief != nil && model.brief.length > 0) {
        self.detailLab.text = model.brief;
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + spaceX, self.titleLab.frame.size.width, model.briefHeight);
    }else {
        self.detailLab.text = @"";
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, self.titleLab.frame.size.width, 0);
    }
    
    UIImage* placeholderImage = [UIImage imageNamed:@"defaultFailedImage"];
    NSURL* imgUrl = [NSURL URLWithString:model.url];
    [self.contentIV sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
    
    self.mediaNameLab.hidden = YES;
    if (model.showMediaName) {
        CGFloat mediaY = self.contentIV.frame.origin.y + self.contentIV.frame.size.height + 10;
        if (self.detailLab.frame.origin.y + self.detailLab.frame.size.height > self.contentIV.frame.origin.y + self.contentIV.frame.size.height) {
            mediaY = self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10;
        }
        self.mediaNameLab.hidden = NO;
        self.mediaNameLab.text = model.mediaName;
        self.mediaNameLab.frame = CGRectMake(10, mediaY, screenWidth - 10 * 2, 15);
    }
    if (model.alreadyRead) {
        self.titleLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.detailLab.textColor = [UIColor colorWithHex:alreadyReadString];
    }else {
        self.titleLab.textColor = [UIColor blackColor];
        self.detailLab.textColor = [UIColor colorWithHex:articleDetailString];
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
