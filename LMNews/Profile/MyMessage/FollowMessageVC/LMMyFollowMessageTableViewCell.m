//
//  LMMyFollowMessageTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/23.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMMyFollowMessageTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMMyFollowMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupDetailView];
    }
    return self;
}

-(void)setupDetailView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, 20)];
        self.contentLab.numberOfLines = 0;
        self.contentLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.contentLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.contentLab.frame = CGRectMake(10, 10, screenWidth - 10 * 2, self.frame.size.height - 10 * 2);
}

-(void)setupMessageContentWithComment:(Comment *)comment {
    RegUser* user = comment.user;
    NSString* nickStr = user.phoneNum;
    if (user.nickname != nil && user.nickname.length > 0) {
        nickStr = user.nickname;
    }
    NSString* contentStr = comment.text;
    NSString* totalStr = [NSString stringWithFormat:@"%@：%@", nickStr, contentStr];
    NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithString:totalStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor blackColor]}];
    [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor colorWithHex:themeOrangeString]} range:NSMakeRange(0, nickStr.length)];
//    self.contentLab.text = totalStr;
    self.contentLab.attributedText = attributedStr;
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
