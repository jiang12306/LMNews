//
//  LMBaseTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Qiwen.pb.h"

@interface LMBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView* lineView;

-(void)showLineView:(BOOL )isShow;

@end
