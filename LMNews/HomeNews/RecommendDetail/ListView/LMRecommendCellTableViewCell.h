//
//  LMRecommendCellTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@interface LMRecommendCellTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* titleLab;

-(void)setupTitleString:(NSString* )titleStr timeString:(NSString* )timeStr;

@end
