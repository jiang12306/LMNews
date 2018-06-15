//
//  LMExploreDetailViewController.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMExploreDetailViewController : LMBaseViewController

@property (nonatomic, assign) NSInteger currentType;/**<探索类型*/
@property (nonatomic, assign) NSInteger orderType;/**<排序方式：0.按关注排序；1.按更新排序*/

@end
