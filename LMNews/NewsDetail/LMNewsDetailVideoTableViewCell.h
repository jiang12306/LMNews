//
//  LMNewsDetailVideoTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import <WebKit/WebKit.h>
#import "LMNewsDetailModel.h"

@interface LMNewsDetailVideoTableViewCell : LMBaseTableViewCell <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView* webView;

@property (nonatomic, strong) UIActivityIndicatorView* aiView;

-(void)setupVideoContent:(LMNewsDetailModel* )model;

@end
