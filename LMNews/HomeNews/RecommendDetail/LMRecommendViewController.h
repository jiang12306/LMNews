//
//  LMRecommendViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/4.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMRecommendViewController : LMBaseViewController

@property (nonatomic, assign) ListType homeType;

-(void)startRefreshRecommendData;

@end
