//
//  LMCommentTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMNewsDetailModel.h"

@class LMCommentTableViewCell;

static CGFloat CommentAvatorIVWidth = 50;
static CGFloat CommentNameFontSize = 18;
static CGFloat CommentContentFontSize = 16;
static CGFloat CommentNameLabHeight = 30;
static CGFloat CommentLikeBtnHeight = 20;


@class LMCommentTableViewCell;

@protocol LMCommentTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMCommentTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMCommentTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮
@end;


typedef void (^LMCommentTableViewCellLikeBlock) (BOOL isLike, LMCommentTableViewCell* likeCell);
typedef void (^LMCommentTableViewCellUnlikeBlock) (BOOL isUnlike, LMCommentTableViewCell* unlikeCell);

@interface LMCommentTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* avatorIV;/**<头像iv*/
@property (nonatomic, strong) UILabel* nameLab;/**<昵称label*/
@property (nonatomic, strong) UILabel* timeLab;/**<时间戳label*/
@property (nonatomic, strong) UILabel* contentLab;/**<评论内容label*/
@property (nonatomic, strong) UIButton* likeBtn;/**<点赞btn*/
@property (nonatomic, strong) UIImageView* likeIV;/**<点赞个数imageview*/
@property (nonatomic, strong) UILabel* likeLab;/**<点赞个数label*/
@property (nonatomic, strong) UIButton* unlikeBtn;/**<踩btn*/
@property (nonatomic, strong) UIImageView* unlikeIV;/**<点赞个数imageview*/
@property (nonatomic, strong) UILabel* unlikeLab;/**<点赞个数label*/

@property (nonatomic, copy) LMCommentTableViewCellLikeBlock likeBlock;
@property (nonatomic, copy) LMCommentTableViewCellUnlikeBlock unlikeBlock;

@property (nonatomic, weak) id<LMCommentTableViewCellDelegate> delegate;

-(void)setupContentWithModel:(LMCommentModel* )model;
//显示/不显示 删除 置顶 按钮
-(void)showDelete:(BOOL )isShow animation:(BOOL)animation;
//是否能左滑删除
-(void)canSpan:(BOOL )can;

@end
