//
//  LMRecommendListTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendListTableViewCell.h"
#import "LMRecommendCellTableViewCell.h"
#import "LMTool.h"

@interface LMRecommendListTableViewCell () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMRecommendListTableViewCell

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentViews];
        
//        self.backgroundColor = [UIColor purpleColor];
    }
    return self;
}

-(void)setupContentViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, 35)];
        self.titleLab.textAlignment = NSTextAlignmentLeft;
        self.titleLab.font = [UIFont systemFontOfSize:titleFontSize];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLab];
    }
    if (!self.tableView) {
        self.dataArray = [NSMutableArray array];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, screenWidth, 20) style:UITableViewStylePlain];
        self.tableView.scrollEnabled = NO;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[LMRecommendCellTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.contentView addSubview:self.tableView];
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    if (!self.mediaNameLab) {
        self.mediaNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.tableView.frame.origin.y + self.tableView.frame.size.height + 10, screenWidth - 10 * 2, 15)];
        self.mediaNameLab.font = [UIFont systemFontOfSize:mediaNameFontSize];
        self.mediaNameLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.mediaNameLab.numberOfLines = 0;
        self.mediaNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.mediaNameLab];
    }
}

#pragma mark -UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return recommendListViewHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMRecommendCellTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LMRecommendCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    LMArticleSimple* simple = [self.dataArray objectAtIndex:indexPath.row];
    NSString* timeString = [LMTool convertTimeStringWithFormartterString:@"YYYY-MM-dd" TimeStamp:simple.t];
    
    [cell setupTitleString:simple.title timeString:timeString];
    
    if (indexPath.row == self.dataArray.count - 1) {
        [cell showLineView:NO];
    }else {
        [cell showLineView:YES];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.cellBlock) {
        self.cellBlock(indexPath.row);
    }
}

-(void)setupContentWithModel:(LMRecommendModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.titleLab.text = model.title;
    self.titleLab.frame = CGRectMake(10, 10, screenWidth - contentIVWidth - spaceX * 3, model.titleHeight);
    
    [self.dataArray removeAllObjects];
    
    LMZhuanTi* zhuanTi = model.zt;
    NSArray* arr = zhuanTi.list;
    if (arr != nil && arr.count > 0) {
        [self.dataArray addObjectsFromArray:arr];
        
        self.tableView.frame = CGRectMake(0, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, screenWidth, recommendListViewHeight * self.dataArray.count);
    }else {
        self.tableView.frame = CGRectMake(0, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, screenWidth, 0);
    }
    [self.tableView reloadData];
    
    self.mediaNameLab.hidden = YES;
    if (model.showMediaName) {
        self.mediaNameLab.hidden = NO;
        self.mediaNameLab.text = model.mediaName;
        self.mediaNameLab.frame = CGRectMake(10, self.tableView.frame.origin.y + self.tableView.frame.size.height + 10, screenWidth - 10 * 2, 15);
    }
    if (model.alreadyRead) {
        self.titleLab.textColor = [UIColor colorWithHex:alreadyReadString];
    }else {
        self.titleLab.textColor = [UIColor blackColor];
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
