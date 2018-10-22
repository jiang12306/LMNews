//
//  LMNewsDetailImageTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailImageTableViewCell.h"
#import "LMRecommendModel.h"
#import "UIImageView+WebCache.h"

@implementation LMNewsDetailImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextLab];
        
//        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

-(void)setupTextLab {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.contentIV) {
        self.contentIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, 100)];
        self.contentIV.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedImageView:)];
        [self.contentIV addGestureRecognizer:tap];
        [self.contentView addSubview:self.contentIV];
    }
    if (!self.textView) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.contentIV.frame.origin.y + self.contentIV.frame.size.height + 10, screenWidth - 10 * 2, 100)];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;
        [self.contentView addSubview:self.textView];
    }
}

-(void)tappedImageView:(UITapGestureRecognizer* )tapGR {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageTableViewCellTappedImageView:)]) {
        [self.delegate imageTableViewCellTappedImageView:self];
    }
}

-(void)setupImageContent:(LMNewsDetailModel *)model indexPath:(NSIndexPath *)indexPath{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat finalImgHeight = screenWidth - 10 * 2;
    if (model.imgHeight) {
        finalImgHeight = model.imgHeight;
    }
    if (model.isSucceed && model.img != nil) {
        self.contentIV.image = model.img;
        self.contentIV.frame = CGRectMake(10, 10, screenWidth - 10 * 2, finalImgHeight);
    }else {
        self.contentIV.frame = CGRectMake(10, 10, screenWidth - 10 * 2, finalImgHeight);
        NSString* imgStr = model.url;
        if (imgStr != nil) {
            [self.contentIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"defaultFailedImage"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                BOOL state = NO;
                BOOL shoulcCallBack = NO;
                if (error == nil && image != nil) {
                    state = YES;
                    model.isSucceed = YES;
                    model.img = image;
                    
                    if (model.imgHeight) {
                        
                    }else {
                        shoulcCallBack = YES;
                        
                        CGFloat imgWidth = image.size.width;
                        CGFloat imgHeight = image.size.height;
                        if (imgWidth > screenWidth - 10 * 2) {
                            model.imgWidth = (screenWidth - 10 * 2);
                            model.imgHeight = (screenWidth - 10 * 2) * imgHeight / imgWidth;
                        }else {
                            model.imgWidth = imgWidth;
                            model.imgHeight = imgHeight;
                        }
                    }
                    
                    self.contentIV.frame = CGRectMake(10, 10, screenWidth - 10 * 2, model.imgHeight);
                    NSAttributedString* str = model.text;
                    if (str != nil && str.length > 0) {
                        self.textView.attributedText = str;
                        self.textView.frame = CGRectMake(10, self.contentIV.frame.origin.y + self.contentIV.frame.size.height + 10, screenWidth - 10 * 2, model.titleHeight);
                    }else {
                        self.textView.frame = CGRectMake(10, 0, screenWidth - 10 * 2, 0);
                    }
                }
                if (shoulcCallBack && self.delegate && [self.delegate respondsToSelector:@selector(imageTableViewCellLoadImageSucceed:cell:indexPath:)]) {
                    [self.delegate imageTableViewCellLoadImageSucceed:state cell:self indexPath:indexPath];
                }
            }];
        }
    }
    NSAttributedString* str = model.text;
    if (str != nil && str.length > 0) {
        self.textView.attributedText = str;
        self.textView.frame = CGRectMake(10, self.contentIV.frame.origin.y + self.contentIV.frame.size.height + 10, screenWidth - 10 * 2, model.titleHeight);
    }else {
        self.textView.frame = CGRectMake(10, 0, screenWidth - 10 * 2, 0);
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
