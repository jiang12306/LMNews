//
//  LMNewsDetailImageTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMNewsDetailModel.h"

@class LMNewsDetailImageTableViewCell;

@protocol LMNewsDetailImageTableViewCellDelegate <NSObject>

@optional
//下载图片回调
-(void)imageTableViewCellLoadImageSucceed:(BOOL )isSucceed cell:(LMNewsDetailImageTableViewCell* )cell indexPath:(NSIndexPath* )indexPath;

-(void)imageTableViewCellTappedImageView:(LMNewsDetailImageTableViewCell* )cell;

@end



@interface LMNewsDetailImageTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) LMNewsDetailModel* imgModel;

@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UIImageView* contentIV;

@property (nonatomic, weak) id<LMNewsDetailImageTableViewCellDelegate> delegate;

-(void)setupImageContent:(LMNewsDetailModel* )model indexPath:(NSIndexPath* )indexPath;

@end
