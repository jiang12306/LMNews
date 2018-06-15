//
//  LMMyCollectionTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@class LMMyCollectionTableViewCell;

@protocol LMMyCollectionTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMMyCollectionTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMMyCollectionTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮

@end;

@interface LMMyCollectionTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id<LMMyCollectionTableViewCellDelegate> delegate;

@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* timeLab;

//显示/不显示 删除 置顶 按钮
-(void)showDelete:(BOOL )isShow animation:(BOOL)animation;

@end
