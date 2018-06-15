//
//  LMProfileDetailViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/22.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"

//登录已过期回调
typedef void (^LMProfileDetailViewControllerBlock) (BOOL isOutTime);

@interface LMProfileDetailViewController : LMBaseViewController

@property (nonatomic, strong) LoginedRegUser* loginedUser;
@property (nonatomic, copy) LMProfileDetailViewControllerBlock loginBlock;

@end
