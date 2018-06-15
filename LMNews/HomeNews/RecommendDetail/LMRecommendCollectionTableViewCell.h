//
//  LMRecommendCollectionTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMRecommendModel.h"

typedef void (^LMRecommendCollectionTableViewCellCollectionBlock) (NSInteger index);

@interface LMRecommendCollectionTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* detailLab;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UILabel* mediaNameLab;

@property (nonatomic, copy) LMRecommendCollectionTableViewCellCollectionBlock itemBlock;

-(void)setupContentWithModel:(LMRecommendModel* )model;

@end
