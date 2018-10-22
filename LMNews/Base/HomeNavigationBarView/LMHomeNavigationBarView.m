//
//  LMHomeNavigationBarView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/28.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMHomeNavigationBarView.h"
#import "LMTool.h"

@implementation LMHomeNavigationBarView

+(CGFloat )getHomeNavigationBarViewHeight {
    CGFloat naviHeight = 20 + 44 - 15;
    if ([LMTool isIPhoneX]) {
        naviHeight = 40 + 44 - 15;
    }
    return naviHeight;
}

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat naviHeight = 20 + 44 - 15;
    if ([LMTool isIPhoneX]) {
        naviHeight = 40 + 44 - 15;
    }
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, naviHeight)];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
