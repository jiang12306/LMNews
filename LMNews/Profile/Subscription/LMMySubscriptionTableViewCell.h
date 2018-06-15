//
//  LMMySubscriptionTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@class LMMySubscriptionTableViewCell;

@protocol LMMySubscriptionTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMMySubscriptionTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMMySubscriptionTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮

@end;

@interface LMMySubscriptionTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;
@property (nonatomic, strong) UILabel* nameLab;//书名 label
@property (nonatomic, strong) UILabel* briefLab;//简介 label

@property (nonatomic, weak) id<LMMySubscriptionTableViewCellDelegate> delegate;

//显示/不显示 删除 置顶 按钮
-(void)showDelete:(BOOL )isShow animation:(BOOL)animation;

@end
