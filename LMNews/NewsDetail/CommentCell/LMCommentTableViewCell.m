//
//  LMCommentTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/16.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMCommentTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LMCommentTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanX;
@property (nonatomic, assign) BOOL isAllowSpan;

@end

@implementation LMCommentTableViewCell

static CGFloat deleteWidth = 70;
static CGFloat slideSpace = 70;//滑动距离 显示/隐藏 置顶 删除 按钮

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupContentViews];
    }
    return self;
}

-(void)setupContentViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.cellView) {
        self.cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, self.frame.size.height)];
        self.cellView.backgroundColor = [UIColor whiteColor];
        [self.contentView insertSubview:self.cellView belowSubview:self.lineView];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didMoveCellView:)];
        self.panGestureRecognizer.delegate = self;
        [self.cellView addGestureRecognizer:self.panGestureRecognizer];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.cellView];
    }
    if (!self.avatorIV) {
        self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, CommentAvatorIVWidth, CommentAvatorIVWidth)];
        self.avatorIV.layer.cornerRadius = CommentAvatorIVWidth / 2;
        self.avatorIV.layer.masksToBounds = YES;
        self.avatorIV.layer.borderColor = [UIColor grayColor].CGColor;
        self.avatorIV.layer.borderWidth = 1.f;
        [self.cellView addSubview:self.avatorIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + 10, 10, 100, CommentNameLabHeight)];
        self.nameLab.textColor = [UIColor colorWithHex:themeOrangeString];
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        self.nameLab.font = [UIFont systemFontOfSize:CommentNameFontSize];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.cellView addSubview:self.nameLab];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, 100, CommentNameLabHeight)];
        self.timeLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.timeLab.textAlignment = NSTextAlignmentLeft;
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.numberOfLines = 0;
        self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.cellView addSubview:self.timeLab];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height + 10, self.nameLab.frame.size.width, 30)];
        self.contentLab.font = [UIFont systemFontOfSize:CommentContentFontSize];
        self.contentLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.contentLab.numberOfLines = 0;
        self.contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.cellView addSubview:self.contentLab];
    }
    if (!self.unlikeBtn) {
        self.unlikeBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - CommentLikeBtnHeight - 10, 25, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        [self.unlikeBtn addTarget:self action:@selector(clickedUnlikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:self.unlikeBtn];
        
        self.unlikeIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        self.unlikeIV.image = [UIImage imageNamed:@"commentUnlike"];
        [self.unlikeBtn addSubview:self.unlikeIV];
        
        self.unlikeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.unlikeIV.frame.origin.x + self.unlikeIV.frame.size.width, self.unlikeIV.frame.origin.y, 0, self.unlikeIV.frame.size.height)];
        self.unlikeLab.font = [UIFont systemFontOfSize:16];
        self.unlikeLab.textColor = [UIColor colorWithHex:themeOrangeString];
        self.unlikeLab.textAlignment = NSTextAlignmentCenter;
        [self.unlikeBtn addSubview:self.unlikeLab];
    }
    if (!self.likeBtn) {
        self.likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - (CommentLikeBtnHeight + 10) * 2, 25, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        [self.likeBtn addTarget:self action:@selector(clickedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:self.likeBtn];
        
        self.likeIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        self.likeIV.image = [UIImage imageNamed:@"commentLike"];
        [self.likeBtn addSubview:self.likeIV];
        
        self.likeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.likeIV.frame.origin.x + self.likeIV.frame.size.width, self.likeIV.frame.origin.y, 0, self.likeIV.frame.size.height)];
        self.likeLab.font = [UIFont systemFontOfSize:16];
        self.likeLab.textColor = [UIColor colorWithHex:themeOrangeString];
        self.likeLab.textAlignment = NSTextAlignmentCenter;
        [self.likeBtn addSubview:self.likeLab];
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

//是否能左滑删除
-(void)canSpan:(BOOL )can {
    if (can) {
        self.isAllowSpan = YES;
    }else {
        self.isAllowSpan = NO;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.cellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
}

-(BOOL )gestureRecognizerShouldBegin:(UIGestureRecognizer* )gestureRecognizer {
    if (!self.isAllowSpan) {
        return NO;
    }
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

-(void)setupContentWithModel:(LMCommentModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    RegUser* user = model.user;
    NSString* imgStr = user.icon;
    if (imgStr != nil && imgStr.length > 0) {
        [self.avatorIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
    }
    self.nameLab.text = user.phoneNum;
    self.nameLab.frame = CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + 10, 10, model.nameWidth, CommentNameLabHeight);
    
    self.timeLab.text = model.time;
    self.timeLab.frame = CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, model.timeWidth, CommentNameLabHeight);
    
    CGFloat tempHeight = model.contentOriginHeight;
    if (model.isFold) {
        tempHeight = model.contentHeight;
    }
    self.contentLab.text = model.text;
    self.contentLab.frame = CGRectMake(10, self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height + 10, screenWidth - 10 * 2, tempHeight);
    
    if (model.downCount != 0) {
        NSString* unlikeStr = [NSString stringWithFormat:@"%ld", (long)model.downCount];
        self.unlikeLab.text = unlikeStr;
        self.unlikeLab.frame = CGRectMake(CommentLikeBtnHeight, 0, model.unlikeWidth, CommentLikeBtnHeight);
        self.unlikeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight - self.unlikeLab.frame.size.width, 25, CommentLikeBtnHeight + self.unlikeLab.frame.size.width, CommentLikeBtnHeight);
    }else {
        self.unlikeLab.text = @"";
        self.unlikeLab.frame = CGRectMake(self.likeIV.frame.origin.x + self.likeIV.frame.size.width, 0, 0, CommentLikeBtnHeight);
        self.unlikeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight, 25, CommentLikeBtnHeight, CommentLikeBtnHeight);
    }
    
    if (model.upCount != 0) {
        NSString* likeStr = [NSString stringWithFormat:@"%ld", (long)model.upCount];
        self.likeLab.text = likeStr;
        self.likeLab.frame = CGRectMake(CommentLikeBtnHeight, 0, model.likeWidth, CommentLikeBtnHeight);
        self.likeBtn.frame = CGRectMake(screenWidth - 10 * 2 - self.unlikeBtn.frame.size.width - CommentLikeBtnHeight - self.likeLab.frame.size.width, 25, CommentLikeBtnHeight + self.likeLab.frame.size.width, CommentLikeBtnHeight);
    }else {
        self.likeLab.text = @"";
        self.likeLab.frame = CGRectMake(self.likeIV.frame.origin.x + self.likeIV.frame.size.width, 0, 0, CommentLikeBtnHeight);
        self.likeBtn.frame = CGRectMake(screenWidth - 10 * 2 - self.unlikeBtn.frame.size.width - CommentLikeBtnHeight, 25, CommentLikeBtnHeight, CommentLikeBtnHeight);
    }
    if (model.isUp) {
        self.likeIV.image = [UIImage imageNamed:@"commentLike_Selected"];
    }else {
        self.likeIV.image = [UIImage imageNamed:@"commentLike"];
    }
    if (model.isDown) {
        self.unlikeIV.image = [UIImage imageNamed:@"commentUnlike_Selected"];
    }else {
        self.unlikeIV.image = [UIImage imageNamed:@"commentUnlike"];
    }
}

-(void)clickedLikeButton:(UIButton* )sender {
    self.likeBlock(YES, self);
}

-(void)clickedUnlikeButton:(UIButton* )sender {
    self.unlikeBlock(YES, self);
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
