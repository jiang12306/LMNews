//
//  LMHomeRightBarButtonItemView.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/31.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMHomeRightBarButtonItemViewBlock) (BOOL didClick);

@interface LMHomeRightBarButtonItemView : UIView

@property (nonatomic, strong) UIButton* bgBtn;
@property (nonatomic, strong) UIImageView* alertIV;
@property (nonatomic, strong) UILabel* dotLab;

@property (nonatomic, copy) LMHomeRightBarButtonItemViewBlock clickBlock;

//设置是否有未读消息
+(void)setupNewMessage:(BOOL )hasMsg;
//是否有未读消息
+(BOOL )hasUnreadMessage;

@end
