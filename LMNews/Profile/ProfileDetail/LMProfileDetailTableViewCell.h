//
//  LMProfileDetailTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/22.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMProfileDetailTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* contentLab;
@property (nonatomic, strong) UIImageView* contentIV;

-(void)setupShowContentLabel:(BOOL )show;
-(void)setupShowContentImageView:(BOOL )show;

@end
