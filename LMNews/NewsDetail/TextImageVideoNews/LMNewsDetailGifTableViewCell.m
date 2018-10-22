//
//  LMNewsDetailGifTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/11.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailGifTableViewCell.h"

@implementation LMNewsDetailGifTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextLab];
        
//        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)setupTextLab {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.webView) {
        self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, (screenWidth - 10 * 2) * 0.618)];
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.scrollView.showsVerticalScrollIndicator = NO;
        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
        self.webView.scrollView.bounces = NO;
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        [self.contentView addSubview:self.webView];
    }
    if (!self.aiView) {
        self.aiView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.aiView.hidesWhenStopped = YES;
        [self.contentView addSubview:self.aiView];
        self.aiView.center = self.webView.center;
        [self.aiView stopAnimating];
        self.aiView.hidden = YES;
    }
    if (!self.textView) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, screenWidth - 10 * 2, 100)];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;
        [self.contentView addSubview:self.textView];
    }
}

-(void)setupGifContent:(LMNewsDetailModel *)model indexPath:(NSIndexPath *)indexPath {
    self.gifModel = model;
    self.gifIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (model.isSucceed) {//单独改变webView的frame没用，还得重新加载url
        self.webView.frame = CGRectMake(10, 10, self.textView.frame.size.width, model.imgHeight);
        
        [self.aiView stopAnimating];
        self.aiView.hidden = YES;
    }else {
        NSString* urlStr = model.gif;
        if (urlStr != nil && urlStr.length > 0) {
            
            self.aiView.center = self.webView.center;
            self.aiView.hidden = NO;
            [self.aiView startAnimating];
            
            NSString* encodeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
            [self.webView loadRequest:[NSURLRequest requestWithURL:encodeUrl]];
        }
    }
    NSAttributedString* str = model.text;
    if (str != nil && str.length > 0) {
        self.textView.attributedText = str;
        self.textView.frame = CGRectMake(10, self.webView.frame.origin.y + self.webView.frame.size.height + 10, screenWidth - 10 * 2, model.titleHeight);
    }else {
        self.textView.frame = CGRectMake(10, 0, screenWidth - 10 * 2, 0);
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [self.webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id data, NSError * _Nullable error) {
        CGFloat height = [data floatValue];
        
        //计算wkWebview中gif高度并赋值给model
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.aiView stopAnimating];
            self.aiView.hidden = YES;
            
            self.gifModel.isSucceed = YES;
            self.gifModel.imgHeight = height;
            
            self.webView.frame = CGRectMake(10, 10, screenWidth - 10 * 2, height);
            NSAttributedString* str = self.gifModel.text;
            if (str != nil && str.length > 0) {
                self.textView.attributedText = str;
                self.textView.frame = CGRectMake(10, self.webView.frame.origin.y + self.webView.frame.size.height + 10, screenWidth - 10 * 2, self.gifModel.titleHeight);
            }else {
                self.textView.frame = CGRectMake(10, 0, screenWidth - 10 * 2, 0);
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(gifTableViewCellLoadImageSucceed:cell:model:indexPath:)]) {
                [self.delegate gifTableViewCellLoadImageSucceed:YES cell:self model:self.gifModel indexPath:self.gifIndexPath];
            }
        });
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
