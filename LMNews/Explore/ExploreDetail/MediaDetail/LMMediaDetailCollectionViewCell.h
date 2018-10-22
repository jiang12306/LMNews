//
//  LMMediaDetailCollectionViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/18.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMRecommendModel.h"

@class LMMediaDetailCollectionViewCell;

typedef void (^LMMediaDetailCollectionViewCellBlock) (BOOL click, LMMediaDetailCollectionViewCell* clickCell);

@interface LMMediaDetailCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView* mediaIV;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UIButton* subBtn;
@property (nonatomic, strong) UIView* bgView;/**<背景*/

@property (nonatomic, copy) LMMediaDetailCollectionViewCellBlock block;

-(void)setupSubscriptionWithSource:(LMSource* )source;

@end
