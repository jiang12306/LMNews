//
//  LMMyMessageModel.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/23.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Qiwen.pb.h"

@interface LMMySystemMessageModel : NSObject

@property (nonatomic, assign) UInt32 msgId;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, copy) NSString* time;
@property (nonatomic, assign) UInt32 isRead;

@property (nonatomic, assign) CGFloat titleHeight;

@end



@interface LMMyFollowMessageModel : NSObject

@property (nonatomic, strong) RegUser* user;
@property (nonatomic, assign) UInt32 articleId;
@property (nonatomic, strong) NSArray<Comment* >* comments;
@property (nonatomic, copy) NSString* nickStr;
@property (nonatomic, copy) NSString* timeStr;

@property (nonatomic, assign) CGFloat nameWidth;
@property (nonatomic, assign) CGFloat timeWidth;
@property (nonatomic, assign) BOOL isFold;

@end
