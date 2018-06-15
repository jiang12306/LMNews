//
//  LMCommentInputView.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/17.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMCommentInputViewBlock) (NSString* inputStr);
@interface LMCommentInputView : UIView

//256个字
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, copy) LMCommentInputViewBlock inputText;

-(void)startShow;
-(void)startHide;

@end
