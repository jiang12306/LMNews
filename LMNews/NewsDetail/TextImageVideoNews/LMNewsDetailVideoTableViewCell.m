//
//  LMNewsDetailVideoTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/10.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMNewsDetailVideoTableViewCell.h"

@implementation LMNewsDetailVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextLab];
        
//        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

-(void)setupTextLab {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.webView) {
        self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, (screenWidth - 10 * 2) * 0.618)];
        self.webView.scrollView.bounces = NO;
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
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(10, self.webView.frame.origin.y + self.webView.frame.size.height + 10, screenWidth - 10 * 2, 0)];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.editable = NO;
        self.textView.scrollEnabled = NO;
        [self.contentView addSubview:self.textView];
    }
}

-(void)setupVideoContent:(LMNewsDetailModel *)model {
    NSString* urlStr = model.url;
    if (urlStr != nil && urlStr.length > 0) {
        
        self.aiView.center = self.webView.center;
        self.aiView.hidden = NO;
        [self.aiView startAnimating];
        
        NSString* encodeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:encodeUrl]];
    }
    NSAttributedString* str = model.text;
    if (str != nil && str.length > 0) {
        self.textView.attributedText = str;
        self.textView.frame = CGRectMake(10, self.webView.frame.origin.y + self.webView.frame.size.height + 10, self.webView.frame.size.width, model.titleHeight);
    }else {
        self.textView.frame = CGRectMake(10, 0, self.webView.frame.size.width, 0);
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.aiView stopAnimating];
    self.aiView.hidden = YES;
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
