//
//  LMImagesNewsFullScreenImage.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/22.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMImagesNewsFullScreenImage;

@protocol LMImagesNewsFullScreenImageDelegate <NSObject>

-(void)imagesNewsFullScreenImageSetupFullScreen:(BOOL )isFullScreen;

@end


@interface LMImagesNewsFullScreenImage : UIView

@property (nonatomic, weak) id <LMImagesNewsFullScreenImageDelegate> delegate;

-(instancetype )initWithFrame:(CGRect)frame textPic:(TextPicVideo* )textPic;

@end
