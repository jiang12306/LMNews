//
//  LMRecommendModel.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/9.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendModel.h"
#import "LMTool.h"

@implementation LMSource

-(id)mutableCopyWithZone:(NSZone *)zone {
    LMSource* lmSource = [LMSource allocWithZone:zone];
    lmSource.sourceName = self.sourceName;
    lmSource.sourceId = self.sourceId;
    lmSource.abstr = self.abstr;
    lmSource.url = self.url;
    lmSource.subCount = self.subCount;
    lmSource.isSub = self.isSub;
    return lmSource;
}

+(LMSource *)convertLMSourceWithSource:(Source *)source {
    LMSource* lmSource = [[LMSource alloc]init];
    lmSource.sourceName = source.sourceName;
    lmSource.sourceId = source.sourceId;
    lmSource.abstr = source.abstr;
    lmSource.url = source.url;
    lmSource.subCount = source.subCount;
    lmSource.isSub = source.isSub;
    return lmSource;
}

@end


//
@implementation LMTextPicVideo

-(id)mutableCopyWithZone:(NSZone *)zone {
    LMTextPicVideo* textPicVideo = [LMTextPicVideo allocWithZone:zone];
    textPicVideo.text = self.text;
    textPicVideo.url = self.url;
    textPicVideo.type = self.type;
    textPicVideo.gif = self.gif;
    return textPicVideo;
}

+(LMTextPicVideo *)convertLMTextPicVideoWithTextPicVideo:(TextPicVideo *)textPicVideo {
    LMTextPicVideo* lmTextPicVideo = [[LMTextPicVideo alloc]init];
    lmTextPicVideo.text = textPicVideo.text;
    lmTextPicVideo.url = textPicVideo.url;
    lmTextPicVideo.type = textPicVideo.type;
    lmTextPicVideo.gif = textPicVideo.gif;
    return lmTextPicVideo;
}

@end



@implementation LMArticleSimple

-(id)mutableCopyWithZone:(NSZone *)zone {
    LMArticleSimple* articleSimple = [LMArticleSimple allocWithZone:zone];
    articleSimple.title = self.title;
    articleSimple.articleId = self.articleId;
    articleSimple.pics = self.pics;
    articleSimple.source = self.source;
    articleSimple.t = self.t;
    articleSimple.commentCount = self.commentCount;
    articleSimple.picCount = self.picCount;
    articleSimple.isAllPic = self.isAllPic;
    return articleSimple;
}

+(LMArticleSimple* )convertLMArticleSimpleWithArticleSimple:(ArticleSimple* )articleSimple {
    LMArticleSimple* lmArticleSimple = [[LMArticleSimple alloc]init];
    lmArticleSimple.title = articleSimple.title;
    lmArticleSimple.articleId = articleSimple.articleId;
    NSMutableArray* lmPicsArr = [NSMutableArray array];
    for (TextPicVideo* textPicVideo in articleSimple.pics) {
        LMTextPicVideo* lmTextPicVideo = [LMTextPicVideo convertLMTextPicVideoWithTextPicVideo:textPicVideo];
        [lmPicsArr addObject:lmTextPicVideo];
    }
    lmArticleSimple.pics = lmPicsArr;
    lmArticleSimple.source = [LMSource convertLMSourceWithSource:articleSimple.source];
    
    lmArticleSimple.t = articleSimple.t;
    lmArticleSimple.commentCount = articleSimple.commentCount;
    lmArticleSimple.picCount = articleSimple.picsCount;
    lmArticleSimple.isAllPic = articleSimple.isAllPic;
    return lmArticleSimple;
}

@end



@implementation LMZhuanTi

-(id)mutableCopyWithZone:(NSZone *)zone {
    LMZhuanTi* lmZhuanTi = [LMZhuanTi allocWithZone:zone];
    lmZhuanTi.title = self.title;
    lmZhuanTi.style = self.style;
    lmZhuanTi.pic = self.pic;
    lmZhuanTi.simple = self.simple;
    lmZhuanTi.list = self.list;
    lmZhuanTi.zhuanTiId = self.zhuanTiId;
    return lmZhuanTi;
}

+(LMZhuanTi *)convertLMZhuanTiWithZhuanTi:(Zhuanti *)zhuanTi {
    LMZhuanTi* lmZhuanTi = [[LMZhuanTi alloc]init];
    lmZhuanTi.title = zhuanTi.title;
    lmZhuanTi.style = zhuanTi.style;
    lmZhuanTi.pic = zhuanTi.pic;
    lmZhuanTi.simple = zhuanTi.simple;
    NSMutableArray* lmSimpleArr = [NSMutableArray array];
    for (ArticleSimple* simple in zhuanTi.list) {
        LMArticleSimple* lmArticleSimple = [LMArticleSimple convertLMArticleSimpleWithArticleSimple:simple];
        [lmSimpleArr addObject:lmArticleSimple];
    }
    lmZhuanTi.list = lmSimpleArr;
    lmZhuanTi.zhuanTiId = zhuanTi.id;
    return lmZhuanTi;
}

@end




@implementation LMRecommendModel




+(CGFloat)caculateRecommendImageLabelWidthWithText:(NSString *)text maxHeight:(CGFloat)maxHeight maxLines:(NSInteger )maxLines font:(UIFont *)font {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, maxHeight)];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (font) {
        lab.font = font;
    }else {
        lab.font = [UIFont systemFontOfSize:titleFontSize];
    }
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, maxHeight)];
    return labSize.width;
}

+(CGFloat)caculateRecommendImageLabelHeightWithAttributedText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth maxLines:(NSInteger )maxLines font:(UIFont *)font {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.attributedText = text;
//    if (font) {
//        lab.font = font;
//    }else {
//        lab.font = [UIFont systemFontOfSize:18];
//    }
    CGSize labSize = [lab sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    if (maxLines != 0) {
        if (labSize.height / lab.font.lineHeight > maxLines) {
            labSize.height = lab.font.lineHeight * maxLines;
        }
    }
    return labSize.height;
}

+(CGFloat)caculateRecommendImageLabelHeightWithText:(NSString *)text maxWidth:(CGFloat)maxWidth maxLines:(NSInteger )maxLines font:(UIFont *)font {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    if (font) {
        lab.font = font;
    }else {
        lab.font = [UIFont systemFontOfSize:titleFontSize];
    }
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    if (maxLines != 0) {
        if (labSize.height / lab.font.lineHeight > maxLines) {
            labSize.height = lab.font.lineHeight * maxLines;
        }
    }
    return labSize.height;
}

+(NSArray *)convertModelWithArray:(NSArray *)arr {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSMutableArray* modelArr = [NSMutableArray array];
    for (ArticleSimpleList* simpleList in arr) {
        LMRecommendModel* model = [[LMRecommendModel alloc]init];
        model.showMediaName = YES;
        model.mediaName = @"专题";
        model.showTime = NO;
        
        UInt32 articleType = simpleList.articleType;
        LMZhuanTi* lmZhuanTi = [LMZhuanTi convertLMZhuanTiWithZhuanTi:simpleList.zt];
        LMArticleSimple* lmArticleSimple = [LMArticleSimple convertLMArticleSimpleWithArticleSimple:simpleList.article];
        if (lmZhuanTi.title != nil && lmZhuanTi.title.length > 0) {
            model.mediaName = [NSString stringWithFormat:@"专题：%@", lmZhuanTi.title];
        }
        if (articleType == 1) {//文章
            model.alreadyRead = [[LMDatabaseTool sharedDatabaseTool]isAlreadyReadArticleWithArticleId:lmArticleSimple.articleId];
            model.title = lmArticleSimple.title;
            model.mediaName = lmArticleSimple.source.sourceName;
            
            model.time = [LMTool convertTimeStringWithFormartterString:@"YYYY-MM-dd HH:mm" TimeStamp:lmArticleSimple.t];//时间戳 热点界面用
            NSInteger commentCount = lmArticleSimple.commentCount;
            NSString* tempCountStr = [NSString stringWithFormat:@"%ld", commentCount];
            if (commentCount == 0) {
                tempCountStr = @"";
            }else if (commentCount > 1000) {
                tempCountStr = @"999+";
            }
            model.commentCountStr = tempCountStr;//评论数 热点界面用
            model.commentWidth = [LMRecommendModel caculateRecommendImageLabelWidthWithText:tempCountStr maxHeight:20 maxLines:1 font:[UIFont systemFontOfSize:mediaNameFontSize]];
            
            NSArray* picsArr = lmArticleSimple.pics;
            if (picsArr == nil || picsArr.count == 0) {//LMRecommendTextTableViewCell
                model.cellStyle = LMRecommendTextTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                model.cellHeight = model.titleHeight + spaceX * 2 + 25;
            }else {
                NSInteger isVideo = NO;
                NSInteger imagesCount = 0;
                NSString* briefStr = nil;
                for (LMTextPicVideo* lmTextPicVideo in picsArr) {
                    NSInteger type = lmTextPicVideo.type;
                    if ((briefStr == nil || briefStr.length == 0) && (lmTextPicVideo.text != nil && lmTextPicVideo.text.length > 0)) {
                        briefStr = lmTextPicVideo.text;
                    }
                    if (type == 2) {
                        isVideo = YES;
                        model.url = lmTextPicVideo.url;
                        break;
                    }else if (type == 1) {
                        if (model.url != nil && model.url.length > 0) {
                            model.url2 = lmTextPicVideo.url;
                        }
                        if (model.url == nil || model.url.length == 0) {
                            model.url = lmTextPicVideo.url;
                        }
                        imagesCount ++;
                    }
                }
                model.brief = briefStr;
                if (isVideo) {//LMRecommendVideoTableViewCell
                    model.cellStyle = LMRecommendVideoTableViewCellStyle;
                    model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                    model.briefHeight = 0;
                    NSInteger spaceCount = 3;
                    if (model.brief != nil && model.brief.length > 0) {
                        model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                        spaceCount = 4;
                    }
                    model.videoHeight = (screenWidth - spaceX * 2) * 0.618;
                    model.cellHeight = model.titleHeight + model.briefHeight + model.videoHeight + spaceX * spaceCount + 25;
                }else {
                    if (imagesCount == 1) {//LMRecommendImageTableViewCell
                        model.cellStyle = LMRecommendImageTableViewCellStyle;
                        model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                        model.briefHeight = 0;
                        NSInteger spaceCount = 2;
                        if (model.brief != nil && model.brief.length > 0) {
                            model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                            spaceCount = 3;
                        }
                        model.cellHeight = model.titleHeight + model.briefHeight + spaceX * spaceCount + 25;
                        if (model.cellHeight < contentIVHeight + spaceX * 2 + 25) {
                            model.cellHeight = contentIVHeight + spaceX * 2 + 25;
                        }
                    }else if (imagesCount == 0) {//LMRecommendTextTableViewCell
                        model.cellStyle = LMRecommendTextTableViewCellStyle;
                        model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                        model.briefHeight = 0;
                        NSInteger spaceCount = 2;
                        if (model.brief != nil && model.brief.length > 0) {
                            model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                            spaceCount = 3;
                        }
                        model.cellHeight = model.titleHeight + model.briefHeight + spaceX * spaceCount + 25;
                    }else {//LMRecommendImagesTableViewCell
                        model.cellStyle = LMRecommendImagesTableViewCellStyle;
                        model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                        model.briefHeight = 0;
                        NSInteger spaceCount = 3;
                        if (model.brief != nil && model.brief.length > 0) {
                            model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                            spaceCount = 4;
                        }
                        model.imageHeight = imagesIVHeight;
                        model.totalImageCount = lmArticleSimple.picCount;
                        model.cellHeight = model.titleHeight + model.briefHeight + model.imageHeight + spaceX * spaceCount + 25;
                    }
                }
            }
        }else if (articleType == 2) {//专题
            model.alreadyRead = [[LMDatabaseTool sharedDatabaseTool]isAlreadyReadZhuanTiWithZhuanTiId:lmZhuanTi.zhuanTiId];
            model.title = lmZhuanTi.title;
            model.brief = lmZhuanTi.simple;
            
            NSInteger style = lmZhuanTi.style;
            if (style == 1) {//LMRecommendCollectionTableViewCell
                model.cellStyle = LMRecommendCollectionTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                NSInteger spaceCount = 0;
                if (lmZhuanTi.list != nil && lmZhuanTi.list.count > 0) {
                    model.collectionViewHeight = recommendCollectionViewHeight;//暂时写死
                    if (model.briefHeight > 0) {
                        spaceCount = 4;
                    }else {
                        spaceCount = 3;
                    }
                }else {
                    model.collectionViewHeight = 0;
                    if (model.briefHeight > 0) {
                        spaceCount = 3;
                    }else {
                        spaceCount = 2;
                    }
                }
                model.cellHeight = model.titleHeight + model.briefHeight + model.collectionViewHeight + spaceX * spaceCount + 25;
            }else if (style == 2) {//LMRecommendListTableViewCell
                model.cellStyle = LMRecommendListTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                model.listViewHeight = lmZhuanTi.list.count * recommendListViewHeight;
                NSInteger spaceCount = 2;
                if (lmZhuanTi.list != nil && lmZhuanTi.list > 0) {
                    spaceCount = 3;
                }
                model.cellHeight = model.titleHeight + model.briefHeight + model.listViewHeight + spaceX * spaceCount + 25;
            }else if (style == 3) {//LMRecommendImageTableViewCell
                model.cellStyle = LMRecommendImageTableViewCellStyle;
                NSArray* tempListArr = lmZhuanTi.list;
                for (LMArticleSimple* tempSimple in tempListArr) {
                    BOOL isContain = NO;
                    NSArray* tempPicsArr = tempSimple.pics;
                    for (LMTextPicVideo* tempPic in tempPicsArr) {
                        if (tempPic.type == 1) {
                            model.url = tempPic.url;
                            isContain = YES;
                            break;
                        }
                    }
                    if (isContain) {
                        break;
                    }
                }
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                NSInteger spaceCount = 2;
                if (model.brief != nil && model.brief.length > 0) {
                    model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    spaceCount = 3;
                }
                model.cellHeight = model.titleHeight + model.briefHeight + spaceX * spaceCount + 25;
                if (model.cellHeight < contentIVHeight + spaceX * 2 + 25) {
                    model.cellHeight = contentIVHeight + spaceX * 2 + 25;
                }
            }else {//LMRecommendTextTableViewCell
                model.cellStyle = LMRecommendTextTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                NSInteger spaceCount = 2;
                if (model.brief != nil && model.brief.length > 0) {
                    model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    spaceCount = 3;
                }
                model.cellHeight = model.titleHeight + model.briefHeight + spaceX * spaceCount + 25;
                if (model.cellHeight < contentIVHeight + spaceX * 2 + 25) {
                    model.cellHeight = contentIVHeight + spaceX * 2 + 25;
                }
            }
        }
        
        model.articleType = articleType;
        model.zt = lmZhuanTi;
        model.article = lmArticleSimple;
        
        
        [modelArr addObject:model];
    }
    return modelArr;
}




+(LMRecommendModel *)convertExploreDataToModelWithArticleSimple:(ArticleSimple *)simple {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    LMRecommendModel* model = [[LMRecommendModel alloc]init];
    LMArticleSimple* lmArticleSimple = [LMArticleSimple convertLMArticleSimpleWithArticleSimple:simple];
    model.article = lmArticleSimple;
    model.title = simple.title;
    model.showMediaName = NO;
    model.alreadyRead = [[LMDatabaseTool sharedDatabaseTool]isAlreadyReadArticleWithArticleId:lmArticleSimple.articleId];
    
    NSArray* picsArr = simple.pics;
    if (picsArr == nil || picsArr.count == 0) {//LMRecommendTextTableViewCell
        model.cellStyle = LMRecommendTextTableViewCellStyle;
        model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
        model.cellHeight = model.titleHeight + spaceX * 2;
    }else {
        NSInteger isVideo = NO;
        NSInteger imagesCount = 0;
        NSString* briefStr = nil;
        for (TextPicVideo* tempVideo in picsArr) {
            NSInteger type = tempVideo.type;
            if ((briefStr == nil || briefStr.length == 0) && (tempVideo.text != nil && tempVideo.text.length > 0)) {
                briefStr = tempVideo.text;
            }
            if (type == 2) {
                isVideo = YES;
                model.url = tempVideo.url;
                break;
            }else if (type == 1) {
                if (model.url != nil && model.url.length > 0) {
                    model.url2 = tempVideo.url;
                }
                if (model.url == nil || model.url.length == 0) {
                    model.url = tempVideo.url;
                }
                imagesCount ++;
            }
        }
        model.brief = briefStr;
        if (isVideo) {//LMRecommendVideoTableViewCell
            model.cellStyle = LMRecommendVideoTableViewCellStyle;
            model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
            model.briefHeight = 0;
            NSInteger spaceCount = 3;
            if (model.brief != nil && model.brief.length > 0) {
                model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                spaceCount = 4;
            }
            model.videoHeight = (screenWidth - spaceX * 2) * 0.618;
            model.cellHeight = model.titleHeight + model.briefHeight + model.videoHeight + spaceX * spaceCount;
        }else {
            if (imagesCount == 1) {//LMRecommendImageTableViewCell
                model.cellStyle = LMRecommendImageTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                NSInteger spaceCount = 2;
                if (model.brief != nil && model.brief.length > 0) {
                model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    spaceCount = 3;
                }
                model.cellHeight = model.titleHeight + model.briefHeight + spaceX * spaceCount;
                if (model.cellHeight < contentIVHeight + spaceX * 2) {
                    model.cellHeight = contentIVHeight + spaceX * 2;
                }
            }else if (imagesCount == 0) {//LMRecommendTextTableViewCell
                model.cellStyle = LMRecommendTextTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                NSInteger spaceCount = 2;
                if (model.brief != nil && model.brief.length > 0) {
                    model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    spaceCount = 3;
                }
                model.cellHeight = model.titleHeight + model.briefHeight  + spaceX * spaceCount;
            }else {//LMRecommendImagesTableViewCell
                model.cellStyle = LMRecommendImagesTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                model.briefHeight = 0;
                NSInteger spaceCount = 3;
                if (model.brief != nil && model.brief.length > 0) {
                    model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(screenWidth - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    spaceCount = 4;
                }
                model.imageHeight = imagesIVHeight;
                model.totalImageCount = lmArticleSimple.picCount;
                model.cellHeight = model.titleHeight + model.briefHeight + model.imageHeight + spaceX * spaceCount;
            }
        }
    }
    
    return model;
}



@end
