//
//  LMExploreDetailModel.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMRecommendModel.h"

@interface LMExploreDetailModel : NSObject

@property (nonatomic, strong) LMSource* lmSource;
@property (nonatomic, copy) NSArray<LMRecommendModel* >* articleList;

+(NSArray* )convertExploreDetailModelWithDataArray:(NSArray* )arr;

@end
