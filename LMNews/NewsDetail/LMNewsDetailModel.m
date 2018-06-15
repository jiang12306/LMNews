//
//  LMNewsDetailModel.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/11.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailModel.h"



@implementation LMCommentModel

+(void)caculateCommentLabelHeightWithText:(NSString *)text maxWidth:(CGFloat)maxWidth maxLines:(NSInteger)maxLines font:(UIFont *)font block:(LMCommentModelBlock)block {
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (font) {
        lab.font = font;
    }else {
        lab.font = [UIFont systemFontOfSize:18];
    }
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    CGFloat totalHeight = labSize.height;
    CGFloat lines = totalHeight / lab.font.lineHeight;
    if (maxLines != 0) {
        if (lines > maxLines) {
            labSize.height = lab.font.lineHeight * maxLines;
        }
    }
    block(labSize.height, totalHeight, lines);
}

@end




@implementation LMNewsDetailModel

+(CGSize )caculateImageHeightWithImage:(UIImage* )img maxWidth:(CGFloat )maxWidth {
    CGFloat imgWidth = img.size.width;
    CGFloat imgHeight = img.size.height;
    CGFloat finalWidth = imgWidth;
    CGFloat finalHeight = imgHeight;
    if (imgWidth > maxWidth) {
        finalWidth = maxWidth;
        finalHeight = maxWidth * imgHeight / imgWidth;
    }
    return CGSizeMake(finalWidth, finalHeight);
}

+(CGSize )caculateImageSizeWithImageWidth:(CGFloat )originWidth imageHeight:(CGFloat )originHeight maxWidth:(CGFloat )maxWidth {
    if (originWidth == 0 || originHeight == 0) {
        return CGSizeMake(0, 0);
    }
    CGFloat finalWidth = originWidth;
    CGFloat finalHeight = originHeight;
    if (originWidth > maxWidth) {
        finalWidth = maxWidth;
        finalHeight = maxWidth * originHeight / originWidth;
    }
    return CGSizeMake(finalWidth, finalHeight);
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    LMNewsDetailModel* model = [LMNewsDetailModel allocWithZone:zone];
    model.text = self.text;
    model.url = self.url;
    model.type = self.type;
    model.gif = self.gif;
    model.isGif = self.isGif;
    model.img = self.img;
    model.isSucceed = self.isSucceed;
    model.titleHeight = self.titleHeight;
    model.imgWidth = self.imgWidth;
    model.imgHeight = self.imgHeight;
    model.cellHeight = self.cellHeight;
    return model;
}

@end
