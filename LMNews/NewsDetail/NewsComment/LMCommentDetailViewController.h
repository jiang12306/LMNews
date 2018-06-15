//
//  LMCommentDetailViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMCommentDetailViewController : LMBaseViewController

//分享用
@property (nonatomic, copy) NSString* articleTitle;/**<标题*/
@property (nonatomic, copy) NSString* articleBrief;/**<简介*/
@property (nonatomic, strong) UIImage* articleImg;/**<weiChat分享用的文章图片*/
@property (nonatomic, copy) NSString* articleImgUrl;/**<qq分享用的文章图片链接*/
@property (nonatomic, copy) NSString* articleUrl;/**<文章url*/

@property (nonatomic, assign) NSInteger articleId;
@property (nonatomic, assign) BOOL isMark;
@property (nonatomic, assign) NSInteger commentCount;

@end
