//
//  LMRecommendImageTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMRecommendModel.h"

@interface LMRecommendImageTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UIImageView* commentIV;
@property (nonatomic, strong) UILabel* commentCountLab;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* detailLab;
@property (nonatomic, strong) UIImageView* contentIV;
@property (nonatomic, strong) UILabel* mediaNameLab;

-(void)setupContentWithModel:(LMRecommendModel* )model;

@end
