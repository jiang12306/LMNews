//
//  LMRecommendListTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMRecommendModel.h"

typedef void (^LMRecommendListTableViewCellBlock) (NSInteger index);

@interface LMRecommendListTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* mediaNameLab;

@property (nonatomic, copy) LMRecommendListTableViewCellBlock cellBlock;

-(void)setupContentWithModel:(LMRecommendModel* )model;

@end
