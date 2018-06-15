//
//  LMRecommendModel.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/9.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Qiwen.pb.h"

static CGFloat spaceX = 10;//间距
static CGFloat contentIVWidth = 100;//单张图片模式下图片宽
static CGFloat contentIVHeight = 75;//单张图片模式下图片高
static CGFloat imagesIVWidth = 200;//多张图片模式下图片宽
static CGFloat imagesIVHeight = 120;//多张图片模式下图片高
static CGFloat mediaNameHeight = 15;//媒体名称label高度
static CGFloat titleFontSize = 18;//标题label字号
static CGFloat detailFontSize = 16;//简介label字号
static CGFloat mediaNameFontSize = 14;//媒体名称label字号
static CGFloat recommendCollectionViewHeight = 150;//LMRecommendCollectionViewCell中collectionView的item高度
static CGFloat recommendListViewHeight = 40;//LMRecommendListTableViewCell中tableView的cell高度

//源
@interface LMSource : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString* sourceName;
@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, copy) NSString* abstr;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, assign) NSInteger subCount;
@property (nonatomic, assign) NSInteger isSub;

+(LMSource* )convertLMSourceWithSource:(Source* )source;

@end



//类型：文本、图片、视频、Gif
@interface LMTextPicVideo : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, assign) NSInteger type;/**<0文字 1图片 2视频 //1图片和2视频 的时候text也可能有内容*/
@property (nonatomic, copy) NSString* gif;

+(LMTextPicVideo* )convertLMTextPicVideoWithTextPicVideo:(TextPicVideo* )textPicVideo;

@end




//文章
@interface LMArticleSimple : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) NSInteger articleId;
@property (nonatomic, strong) NSArray<LMTextPicVideo*>* pics;
@property (nonatomic, strong) LMSource* source;
@property (nonatomic, assign) UInt64 t;
@property (nonatomic, assign) UInt64 commentCount;
@property (nonatomic, assign) NSInteger picCount;


+(LMArticleSimple* )convertLMArticleSimpleWithArticleSimple:(ArticleSimple* )articleSimple;

@end




//专题
@interface LMZhuanTi : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) NSInteger style;/**<1左右滑动块；2时间线文章标题；3一图+标题*/
@property (nonatomic, copy) NSString* pic;
@property (nonatomic, copy) NSString* simple;
@property (nonatomic, strong) NSArray<LMArticleSimple*>* list;
@property (nonatomic, assign) NSInteger zhuanTiId;/**<*/

+(LMZhuanTi* )convertLMZhuanTiWithZhuanTi:(Zhuanti* )zhuanTi;

@end



typedef enum {
    LMRecommendImageTableViewCellStyle = 1,
    LMRecommendVideoTableViewCellStyle = 2,
    LMRecommendImagesTableViewCellStyle = 3,
    LMRecommendTextTableViewCellStyle = 4,
    LMRecommendCollectionTableViewCellStyle = 5,
    LMRecommendListTableViewCellStyle = 6,
}LMRecommendModelCellStyle;

@interface LMRecommendModel : NSObject

/**
 * 1.LMRecommendImageTableViewCell
 * 2.LMRecommendVideoTableViewCell
 * 3.LMRecommendImagesTableViewCell
 * 4.LMRecommendTextTableViewCell
 * 5.LMRecommendCollectionTableViewCell
 * 6.LMRecommendListTableViewCell
 */
@property (nonatomic, assign) LMRecommendModelCellStyle cellStyle;

@property (nonatomic, assign) BOOL alreadyRead;/**<是否已读 YES:已读, NO:未读*/
@property (nonatomic, copy) NSString* title;//标题
@property (nonatomic, copy) NSString* url;//单张图片图片、视频url
@property (nonatomic, copy) NSString* url2;//LMRecommendImagesTableViewCell模式下第二张图片的url

@property (nonatomic, assign) BOOL showTime;//是否显示时间戳   热点界面用
@property (nonatomic, copy) NSString* time;//时间戳   热点界面用
@property (nonatomic, copy) NSString* commentCountStr;//评论数  热点界面用
//@property (nonatomic, assign) CGFloat commentWidth;//评论数宽度  热点界面用

@property (nonatomic, assign) BOOL showMediaName;//是否显示媒体名称
@property (nonatomic, copy) NSString* mediaName;//专题时显示“专题”；文章显示媒体名称
@property (nonatomic, copy) NSString* brief;//简介
@property (nonatomic, assign) CGFloat cellHeight;//总的cell高度
@property (nonatomic, assign) CGFloat titleHeight;//标题 高度
@property (nonatomic, assign) CGFloat briefHeight;//
@property (nonatomic, assign) CGFloat imageHeight;//
@property (nonatomic, assign) CGFloat videoHeight;//
@property (nonatomic, assign) CGFloat collectionViewHeight;//
@property (nonatomic, assign) CGFloat listViewHeight;//

@property (nonatomic, assign) NSInteger articleType;/**<1.文章；2.专题*/
@property (nonatomic, strong) LMArticleSimple* article;
@property (nonatomic, strong) LMZhuanTi* zt;



/**
 * @param font default font 18
 */
+(CGFloat )caculateRecommendImageLabelWidthWithText:(NSString* )text maxHeight:(CGFloat )maxHeight maxLines:(NSInteger )maxLines font:(UIFont* )font;

/**
 * @param font default font 18
 */
+(CGFloat)caculateRecommendImageLabelHeightWithAttributedText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth maxLines:(NSInteger )maxLines font:(UIFont *)font;

/**
 * @param font default font 18
 */
+(CGFloat )caculateRecommendImageLabelHeightWithText:(NSString* )text maxWidth:(CGFloat )maxWidth maxLines:(NSInteger )maxLines font:(UIFont* )font;

/**
 *  将首页中 推荐、关注、热点 页面数据转换成model
 */
+(NSArray* )convertModelWithArray:(NSArray* )arr;


/**
 *  将探索中 奇闻、段子 等页面数据转换成model
 */
+(LMRecommendModel* )convertExploreDataToModelWithArticleSimple:(ArticleSimple* )simple;

@end
