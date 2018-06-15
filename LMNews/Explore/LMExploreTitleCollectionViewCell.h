//
//  LMExploreTitleCollectionViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMExploreTitleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UIView* lineView;

-(void)setupSelected:(BOOL )isCurrent;

@end
