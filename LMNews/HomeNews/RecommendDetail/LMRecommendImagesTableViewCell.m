//
//  LMRecommendImagesTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendImagesTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMRecommendImagesTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentViews];
        
//        self.backgroundColor = [UIColor yellowColor];
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
        self.commentIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.commentCountLab.frame.origin.x - 20 - 5, 10, 20, 18)];
        self.commentIV.image = [UIImage imageNamed:@"comment_Bubble"];
        [self.contentView addSubview:self.commentIV];
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, 35)];
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
    if (!self.contentIV1) {
        self.contentIV1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, imagesIVWidth, imagesIVHeight)];
        self.contentIV1.contentMode = UIViewContentModeScaleAspectFill;
        self.contentIV1.clipsToBounds = YES;
        [self.contentView addSubview:self.contentIV1];
    }
    if (!self.contentIV2) {
        self.contentIV2 = [[UIImageView alloc]initWithFrame:CGRectMake(imagesIVWidth + 10 * 2, self.contentIV1.frame.origin.y, screenWidth - imagesIVWidth - 10 * 3, imagesIVHeight)];
        self.contentIV2.contentMode = UIViewContentModeScaleAspectFill;
        self.contentIV2.clipsToBounds = YES;
        [self.contentView addSubview:self.contentIV2];
    }
    if (!self.mediaNameLab) {
        self.mediaNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.contentIV1.frame.origin.y + self.contentIV1.frame.size.height + 10, screenWidth - 10 * 2, 20)];
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
        self.commentIV.hidden = NO;
        self.commentCountLab.hidden = NO;
        self.commentCountLab.text = model.commentCountStr;
        startY = self.timeLab.frame.origin.y + self.timeLab.frame.size.height + 10;
    }
    
    self.titleLab.text = model.title;
    self.titleLab.frame = CGRectMake(10, startY, screenWidth - spaceX * 2, model.titleHeight);
    
    if (model.brief != nil && model.brief.length > 0 && model.briefHeight != 0) {
        self.detailLab.text = model.brief;
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + spaceX, self.titleLab.frame.size.width, model.briefHeight);
    }else {
        self.detailLab.text = @"";
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, self.titleLab.frame.size.width, 0);
    }
    
    self.contentIV1.frame = CGRectMake(10, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, imagesIVWidth, imagesIVHeight);
    UIImage* placeholderImage = [UIImage imageNamed:@"defaultFailedImage"];
    NSURL* imgUrl1 = [NSURL URLWithString:model.url];
    [self.contentIV1 sd_setImageWithURL:imgUrl1 placeholderImage:placeholderImage];
    
    self.contentIV2.frame = CGRectMake(imagesIVWidth + 10 * 2, self.contentIV1.frame.origin.y, screenWidth - imagesIVWidth - 10 * 3, imagesIVHeight);
    NSURL* imgUrl2 = [NSURL URLWithString:model.url2];
    [self.contentIV2 sd_setImageWithURL:imgUrl2 placeholderImage:placeholderImage];
    
    self.mediaNameLab.hidden = YES;
    if (model.showMediaName) {
        self.mediaNameLab.hidden = NO;
        self.mediaNameLab.text = model.mediaName;
        self.mediaNameLab.frame = CGRectMake(10, self.contentIV1.frame.origin.y + self.contentIV1.frame.size.height + 10, screenWidth - 10 * 2, 20);
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