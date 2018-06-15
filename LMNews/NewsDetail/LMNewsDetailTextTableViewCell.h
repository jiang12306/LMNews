//
//  LMNewsDetailTextTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMNewsDetailModel.h"

@interface LMNewsDetailTextTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* textLab;

-(void)setupTextContent:(LMNewsDetailModel* )model;

@end
