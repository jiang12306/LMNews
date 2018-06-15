//
//  LMMyFollowMessageTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/23.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMMyMessageModel.h"

static CGFloat followMessageCellAvatorWIdth = 50;

@interface LMMyFollowMessageTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* contentLab;/**<消息内容*/

-(void)setupMessageContentWithComment:(Comment* )comment;

@end
