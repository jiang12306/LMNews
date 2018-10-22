//
//  LMImagesNewsFullScreenImage.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/22.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMImagesNewsFullScreenImage.h"
#import "LMTool.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@interface LMImagesNewsFullScreenImage () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIImageView* photoIV;
@property (nonatomic, strong) UIView* textBGView;
@property (nonatomic, strong) UILabel* textLab;
@property (nonatomic, assign) NSInteger downloadState;/**<图片是否加载完成 0.未加载或未加载 1.加载成功；2.加载失败*/
@property (nonatomic, copy) NSString* imgUrlStr;
@property (nonatomic, strong) UIActivityIndicatorView* aiView;

@end

@implementation LMImagesNewsFullScreenImage

-(instancetype)initWithFrame:(CGRect)frame textPic:(TextPicVideo *)textPic {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.scrollView.clipsToBounds = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.maximumZoomScale = 2.0;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        self.photoIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.photoIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.photoIV];
        
        self.aiView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.aiView.hidesWhenStopped = YES;
        [self insertSubview:self.aiView aboveSubview:self.scrollView];
        self.aiView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.aiView.hidden = YES;
        [self.aiView stopAnimating];
        
        self.downloadState = 0;
        self.imgUrlStr = textPic.url;
        UIImage* tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:self.imgUrlStr];
        if (tempImg != nil) {
            self.downloadState = 1;
            self.photoIV.image = tempImg;
        }else {
            //
            [self startLoadImage];
        }
        
        CGFloat bottomY = 44;
        if ([LMTool isIPhoneX]) {
            bottomY += 40;
        }
        self.textBGView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - bottomY, frame.size.width, 0)];
        self.textBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self insertSubview:self.textBGView aboveSubview:self.photoIV];
        
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, frame.size.width - 10 * 2, 0)];
        self.textLab.backgroundColor = [UIColor clearColor];
        self.textLab.font = [UIFont systemFontOfSize:16];
        self.textLab.textAlignment = NSTextAlignmentLeft;
        self.textLab.textColor = [UIColor whiteColor];
        self.textLab.numberOfLines = 0;
        [self.textBGView addSubview:self.textLab];
        
        NSString* str = textPic.text;
        self.textLab.text = str;
        CGSize labSize = [self.textLab sizeThatFits:CGSizeMake(frame.size.width - 10 * 2, CGFLOAT_MAX)];
        self.textBGView.frame = CGRectMake(0, frame.size.height - bottomY - labSize.height, frame.size.width, labSize.height);
        self.textLab.frame = CGRectMake(10, 0, frame.size.width - 10 * 2, labSize.height);
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTappedView:)];
        [self addGestureRecognizer:singleTap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedView:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
    }
    
    return self;
}

-(void)startLoadImage {
    self.downloadState = 0;
    
    self.aiView.hidden = NO;
    [self.aiView startAnimating];
    
    [self.photoIV sd_setImageWithURL:[NSURL URLWithString:self.imgUrlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.aiView stopAnimating];
        self.aiView.hidden = YES;
        if (image && error == nil) {
            self.downloadState = 1;
            
        }else {
            self.downloadState = 2;
        }
    }];
}

-(void)singleTappedView:(UITapGestureRecognizer* )tapGR {
    if (self.downloadState == 0) {
        return;
    }else if (self.downloadState == 2) {
        //
        [self startLoadImage];
        
        return;
    }
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect labRect = self.textBGView.frame;
    CGFloat bottomY = 44;
    if ([LMTool isIPhoneX]) {
        bottomY += 40;
    }
    BOOL isFullScreen = NO;
    if (self.textBGView.hidden == YES) {
        self.textBGView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.textBGView.frame = CGRectMake(0, screenRect.size.height - labRect.size.height - bottomY, screenRect.size.width, labRect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }else {
        isFullScreen = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.textBGView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, labRect.size.height);
        } completion:^(BOOL finished) {
            self.textBGView.hidden = YES;
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagesNewsFullScreenImageSetupFullScreen:)]) {
        [self.delegate imagesNewsFullScreenImageSetupFullScreen:isFullScreen];
    }
}

-(void)doubleTappedView:(UITapGestureRecognizer* )tapGR {
    if (self.downloadState == 0) {
        return;
    }else if (self.downloadState == 2) {
        //
        [self startLoadImage];
        
        return;
    }
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint point = [tapGR locationInView:tapGR.view];
        CGFloat touchX = point.x;
        CGFloat touchY = point.y;
        touchX *= 1/self.scrollView.zoomScale;
        touchY *= 1/self.scrollView.zoomScale;
        touchX += self.scrollView.contentOffset.x;
        touchY += self.scrollView.contentOffset.y;
        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale withCenter:CGPointMake(touchX, touchY)];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

-(CGRect )zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.photoIV.center = [self centerOfScrollViewContent:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoIV;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.scrollView.userInteractionEnabled = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
