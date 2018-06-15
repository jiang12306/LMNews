//
//  LMProfileTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMProfileTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* dotLab;/**<黄点标记*/

/**隐藏 黄点 标记
 *  @prama isHidden : 是否隐藏
 */
-(void)setupDotLabelHidden:(BOOL )isHidden;

@end
