//
//  LMNewsDetailModel.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/11.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Qiwen.pb.h"

typedef void (^LMCommentModelBlock) (CGFloat labHeight, CGFloat labOriginHeight, NSInteger lines);/**<labHeight：根据行数计算所得高度；labOriginHeight：文本总共高度；lines：行数*/

@interface LMCommentModel : NSObject

@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, assign) NSInteger articleId;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, strong) RegUser* user;
@property (nonatomic, assign) NSInteger prevId;
@property (nonatomic, assign) NSInteger prevUid;
@property (nonatomic, strong) RegUser* prevUser;
@property (nonatomic, assign) NSInteger upCount;
@property (nonatomic, assign) NSInteger downCount;
@property (nonatomic, copy) NSString* time;
@property (nonatomic, assign) BOOL isUp;
@property (nonatomic, assign) BOOL isDown;

@property (nonatomic, assign) CGFloat likeWidth;/**<点赞label 宽度*/
@property (nonatomic, assign) CGFloat unlikeWidth;/**<踩label 宽度*/
@property (nonatomic, assign) CGFloat nameWidth;/**<昵称label宽*/
@property (nonatomic, assign) CGFloat timeWidth;/**<时间戳宽度*/
@property (nonatomic, assign) CGFloat contentHeight;/**<评论内容被折叠之后高度*/
@property (nonatomic, assign) CGFloat contentOriginHeight;/**<评论内容原始高度*/
@property (nonatomic, assign) BOOL isFold;

/**
 * @param font default font 18
 */
+(void )caculateCommentLabelHeightWithText:(NSString* )text maxWidth:(CGFloat )maxWidth maxLines:(NSInteger )maxLines font:(UIFont* )font block:(LMCommentModelBlock )block;

@end



@interface LMNewsDetailModel : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSAttributedString* text;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString* gif;

@property (nonatomic, assign) BOOL isGif;/**是否是gif，前端根据type=1且gif有值综合判断*/
@property (nonatomic, strong) UIImage* img;
@property (nonatomic, assign) BOOL isSucceed;

@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;
@property (nonatomic, assign) CGFloat cellHeight;

//根据图片以及最大宽度计算高度
+(CGSize )caculateImageHeightWithImage:(UIImage* )img maxWidth:(CGFloat )maxWidth;

//根据后台给的宽高适配屏幕计算最终宽高
+(CGSize )caculateImageSizeWithImageWidth:(CGFloat )originWidth imageHeight:(CGFloat )originHeight maxWidth:(CGFloat )maxWidth;


+(CGFloat )caculateTextViewHeightWithText:(NSAttributedString* )text maxWidth:(CGFloat )maxWidth font:(UIFont* )font;
@end
