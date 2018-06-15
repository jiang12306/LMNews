//
//  LMNetworkTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LMNetworkToolSuccessBlock) (NSData* successData);
typedef void (^LMNetworkToolFailueBlock) (NSError* failureError);

static NSString* aboutUsHost = @"http://book.yeseshuguan.com/apk/about.htm";
static NSString* copyrightHost = @"http://book.yeseshuguan.com/apk/cr.htm";

static NSString* urlHost = @"http://qiwen.tkmob.com/api/index";

@interface LMNetworkTool : NSObject


+(instancetype )sharedNetworkTool;

-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;

//-(NSData* )postSyncWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData;

//cmd=20 专门用来修改个人信息用，需要校验token有效期
//-(void)postCheckTokenWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;

@end
