//
//  LMExploreDetailModel.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMExploreDetailModel.h"

@implementation LMExploreDetailModel

+(NSArray *)convertExploreDetailModelWithDataArray:(NSArray *)arr {
    NSMutableArray* modelsArr = [NSMutableArray array];
    for (SourceArticle* article in arr) {
        LMExploreDetailModel* model = [[LMExploreDetailModel alloc]init];
        model.lmSource = [LMSource convertLMSourceWithSource:article.source];
        
        NSMutableArray* tempArticleArr = [NSMutableArray array];
        
        NSArray* articleArr = article.articleList;
        for (ArticleSimple* simple in articleArr) {
            LMRecommendModel* recommendModel = [LMRecommendModel convertExploreDataToModelWithArticleSimple:simple];
            
            [tempArticleArr addObject:recommendModel];
        }
        model.articleList = tempArticleArr;
        
        [modelsArr addObject:model];
    }
    
    return modelsArr;
}

@end
