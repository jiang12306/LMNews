//
//  LMCommentInputView.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMCommentInputView.h"

@interface LMCommentInputView () <UITextViewDelegate>

@property (nonatomic, strong) UILabel* limitLab;

@end

@implementation LMCommentInputView

static CGFloat BGViewHeight = 80;
NSInteger limitCount = 256;
NSString* limitStr = @"不超过256字";

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self];
        self.hidden = YES;
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, BGViewHeight)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, screenRect.size.width - 10 * 2, BGViewHeight - 20)];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.delegate = self;
        self.textView.layer.borderColor = [UIColor grayColor].CGColor;
        self.textView.layer.borderWidth = 1.f;
        self.textView.returnKeyType = UIReturnKeySend;
        [self.bgView addSubview:self.textView];
        
        self.limitLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 2, 100, 30)];
        self.limitLab.font = [UIFont systemFontOfSize:16];
        self.limitLab.textColor = [UIColor grayColor];
        self.limitLab.text = limitStr;
        [self.textView addSubview:self.limitLab];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)startShow {
    [self.textView becomeFirstResponder];
}

-(void)startHide {
    [self.textView resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification* )notify {
    self.hidden = NO;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect keyboardFrame = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float duration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height - keyboardFrame.size.height - BGViewHeight, screenRect.size.width, BGViewHeight);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)keyboardWillHide:(NSNotification* )notify {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    float duration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, BGViewHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    UIView* touchView = touch.view;
    if (touchView != self.bgView) {
        [self startHide];
    }
}

#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){//判断输入的字是否是回车，即按下return
        [self.textView resignFirstResponder];
        self.inputText(self.textView.text);
        return NO;
    }
    if (self.textView.text.length + text.length > limitCount) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textView.text.length > 0) {
        self.limitLab.hidden = YES;
    }else {
        self.limitLab.hidden = NO;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
