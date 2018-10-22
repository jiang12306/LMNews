//
//  LMNewsDetailGifTableViewCell.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/11.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import <WebKit/WebKit.h>
#import "LMNewsDetailModel.h"

@class LMNewsDetailGifTableViewCell;

@protocol LMNewsDetailGifTableViewCellDelegate <NSObject>

@optional
//下载gif回调
-(void)gifTableViewCellLoadImageSucceed:(BOOL )isSucceed cell:(LMNewsDetailGifTableViewCell* )cell model:(LMNewsDetailModel* )model indexPath:(NSIndexPath* )indexPath;

@end

@interface LMNewsDetailGifTableViewCell : LMBaseTableViewCell <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) LMNewsDetailModel* gifModel;
@property (nonatomic, strong) NSIndexPath* gifIndexPath;
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) WKWebView* webView;

@property (nonatomic, strong) UIActivityIndicatorView* aiView;

@property (nonatomic, weak) id<LMNewsDetailGifTableViewCellDelegate> delegate;

-(void)setupGifContent:(LMNewsDetailModel* )model indexPath:(NSIndexPath* )indexPath;

@end
