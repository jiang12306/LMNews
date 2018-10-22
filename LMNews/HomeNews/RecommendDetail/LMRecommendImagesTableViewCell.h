//
//  LMRecommendImagesTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMRecommendModel.h"

@interface LMRecommendImagesTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UIImageView* commentIV;
@property (nonatomic, strong) UILabel* commentCountLab;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* detailLab;
@property (nonatomic, strong) UIImageView* contentIV1;
@property (nonatomic, strong) UIImageView* contentIV2;
@property (nonatomic, strong) UILabel* totalCountLab;/**<图片数量 label*/
@property (nonatomic, strong) UILabel* mediaNameLab;

-(void)setupContentWithModel:(LMRecommendModel* )model;

@end
