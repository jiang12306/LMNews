//
//  LMFastLoginViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/21.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMFastLoginBlock) (LoginedRegUser* loginUser);

@interface LMFastLoginViewController : LMBaseViewController

@property (nonatomic, copy) LMFastLoginBlock userBlock;

@end
