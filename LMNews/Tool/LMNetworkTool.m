//
//  LMNetworkTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMNetworkTool.h"
#import "AFNetworking.h"
#import "Qiwen.pb.h"
#import "LMTool.h"

@implementation LMNetworkTool

static LMNetworkTool *_sharedNetworkTool;
static dispatch_once_t onceToken;

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (_sharedNetworkTool == nil) {
            _sharedNetworkTool = [super allocWithZone:zone];
            
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
            
        }
    });
    return _sharedNetworkTool;
}

-(id)copyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

+(instancetype)sharedNetworkTool {
    if (!_sharedNetworkTool) {
        _sharedNetworkTool = [[self alloc]init];
    }
    return _sharedNetworkTool;
}




-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock {
    
    GpsBuilder* gpsBuilder = [Gps builder];
    [gpsBuilder setCoordinateType:GpsCoordinateTypeWgs84];
    [gpsBuilder setLatitude:0];
    [gpsBuilder setLongitude:0];
    [gpsBuilder setTimestamp:[LMTool get10NumbersTimeStamp]];
    Gps* gps = [gpsBuilder build];
    
    QiWenApiReqBuilder* apiBuilder = [QiWenApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    if (reqData != nil) {
        [apiBuilder setBody:reqData];
    }
    //GPS
    [apiBuilder setGps:gps];
    //LoginedRegUser
    LoginedRegUser* tempLogUser = [LMTool getLoginedRegUser];
    if (tempLogUser != nil && tempLogUser.token.length > 0) {
        [apiBuilder setLoginedUser:tempLogUser];
    }
    [apiBuilder setVerName:[LMTool applicationCurrentVersion]];
    
    QiWenApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?cmd=%d", urlHost, cmd]];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;//[postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL isError = NO;
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (error) {
            failureBlock(error);
        } else {
            NSError* tempErr = nil;
            if (responseStatusCode != 200) {
                isError = YES;
                NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"未知错误", NSLocalizedDescriptionKey, @"protobuf协议出错", NSLocalizedFailureReasonErrorKey,nil];
                tempErr = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:responseStatusCode userInfo:userInfoDic];
            }
            @try {
                QiWenApiRes* apiRes = [QiWenApiRes parseFromData:data];
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
                
            } @catch (NSException *exception) {
                isError = YES;
                failureBlock(tempErr);
            } @finally {
                if (isError) {
                    failureBlock(tempErr);
                }else {
                    successBlock(data);
                }
            }
            
        }
    }];
    [dataTask resume];
}






@end
