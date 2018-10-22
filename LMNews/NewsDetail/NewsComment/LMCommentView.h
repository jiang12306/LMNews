//
//  LMCommentView.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseAlertView.h"

//点击评论回调
typedef void (^LMCommentViewTextBlock) (BOOL didStart);
//点击显示评论、置顶回调
typedef void (^LMCommentViewCommentNumBlock) (BOOL showComment);
//点击分享回调
typedef void (^LMCommentViewShareBlock) (BOOL didStart);
//点击收藏回调
typedef void (^LMCommentViewCollectBlock) (BOOL didStart);

@interface LMCommentView : LMBaseAlertView

@property (nonatomic, strong) UIButton* shareBtn;/**<分享按钮*/
@property (nonatomic, strong) UIButton* collectBtn;/**<（取消）收藏按钮*/
@property (nonatomic, strong) UIButton* commentNumBtn;/**<显示评论按钮*/
@property (nonatomic, strong) UILabel* commentNumLab;/**<评论数量label*/
@property (nonatomic, strong) UIButton* startInputBtn;/**<点击评论按钮*/

@property (nonatomic, copy) LMCommentViewTextBlock commentBlock;
@property (nonatomic, copy) LMCommentViewCommentNumBlock numBlock;
@property (nonatomic, copy) LMCommentViewShareBlock shareBlock;
@property (nonatomic, copy) LMCommentViewCollectBlock collectBlock;

-(void)setupCollectedState:(BOOL )isCollect;

//设置评论数
-(void)setupCommentCount:(NSInteger )commentCount;


@end
