//
//  LMMySubscriptionTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/7.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMySubscriptionTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LMMySubscriptionTableViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮

@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanX;

@end

@implementation LMMySubscriptionTableViewCell

static CGFloat deleteWidth = 80;
static CGFloat slideSpace = 40;//滑动距离 显示/隐藏 置顶 删除 按钮
static CGFloat spaceX = 10;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.cellView) {
        self.cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, self.frame.size.height)];
        self.cellView.backgroundColor = [UIColor whiteColor];
        [self.contentView insertSubview:self.cellView belowSubview:self.lineView];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didMoveCellView:)];
        self.panGestureRecognizer.delegate = self;
        [self.cellView addGestureRecognizer:self.panGestureRecognizer];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.deleteBtn setTitle:@"取消订阅" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.lineView];
    }
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceX, spaceX, 50, 50)];
        self.coverIV.layer.cornerRadius = 25;
        self.coverIV.layer.masksToBounds = YES;
        [self.cellView addSubview:self.coverIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceX, self.coverIV.frame.origin.y, screenRect.size.width - self.coverIV.frame.size.width - spaceX * 3, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        [self.cellView addSubview:self.nameLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 10, self.nameLab.frame.size.width, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:14];
        self.briefLab.textColor = [UIColor colorWithRed:63.f/255 green:63.f/255 blue:63.f/255 alpha:1];
        [self.cellView addSubview:self.briefLab];
    }
}

//点击 删除 按钮
-(void)clickedDeleteButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:deleteButton:)]) {
        [self.delegate didClickCell:self deleteButton:self.deleteBtn];
    }
}

//显示/不显示 删除 置顶 按钮
-(void)showDelete:(BOOL )isShow animation:(BOOL)animation {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect cellViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect deleteBtnFrame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
    if (isShow) {
        cellViewFrame = CGRectMake(- (deleteWidth), 0, self.frame.size.width, self.frame.size.height);
        deleteBtnFrame = CGRectMake(screenRect.size.width - (deleteWidth), 0, deleteWidth, self.frame.size.height);
    }
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cellView.frame = cellViewFrame;
            self.deleteBtn.frame = deleteBtnFrame;
        } completion:^(BOOL finished) {
            
        }];
        return;
    }else {
        self.cellView.frame = cellViewFrame;
        self.deleteBtn.frame = deleteBtnFrame;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.cellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
}

-(BOOL )gestureRecognizerShouldBegin:(UIGestureRecognizer* )gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint startPoint = [gestureRecognizer locationInView:self.cellView];
        if (startPoint.x < 80) {
            return NO;
        }
        
        CGPoint point = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view];
        return fabs(point.y) <= fabs(point.x);
    }else {
        return YES;
    }
}

-(void)didMoveCellView:(UIPanGestureRecognizer* )panGR {
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.startPanX = [panGR locationInView:self.cellView].x;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartScrollCell:)]) {
            [self.delegate didStartScrollCell:self];
        }
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.cellView.frame;
        startFrame.origin.x = startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) < - (deleteWidth) ? - (deleteWidth) : (startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) > 0 ? 0 : startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX));
        self.cellView.frame = startFrame;
        self.deleteBtn.frame = CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, deleteWidth, self.frame.size.height);
    }else if (panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled) {
        CGFloat endFrameX = self.cellView.frame.origin.x;
        if (endFrameX > - slideSpace) {
            [self showDelete:NO animation:YES];
        }else {
            [self showDelete:YES animation:YES];
        }
    }
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
