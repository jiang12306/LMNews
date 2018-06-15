//
//  LMMySystemMessageTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/23.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMMyMessageModel.h"

@interface LMMySystemMessageTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* timeLab;

-(void)setupMessageContentWithModel:(LMMySystemMessageModel* )model;

@end
