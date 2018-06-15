//
//  LMRecommendCollectionTableViewCell.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/15.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMRecommendCollectionTableViewCell.h"
#import "LMRecommendCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface LMRecommendCollectionTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMRecommendCollectionTableViewCell

static NSString* collectionViewIdentifier = @"collectionViewIdentifier";

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContentViews];
        
//        self.backgroundColor = [UIColor blueColor];
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
    if (!self.detailLab) {
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.titleLab.frame.size.width, 30)];
        self.detailLab.font = [UIFont systemFontOfSize:detailFontSize];
        self.detailLab.textColor = [UIColor colorWithHex:articleDetailString];
        self.detailLab.numberOfLines = 0;
        self.detailLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.detailLab];
    }
    if (!self.collectionView) {
        self.dataArray = [NSMutableArray array];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, screenWidth, 100) collectionViewLayout:layout];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.alwaysBounceHorizontal = YES;
        self.collectionView.alwaysBounceVertical = NO;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[LMRecommendCollectionViewCell class] forCellWithReuseIdentifier:collectionViewIdentifier];
        [self.contentView addSubview:self.collectionView];
    }
    if (!self.mediaNameLab) {
        self.mediaNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, screenWidth - 10 * 2, 20)];
        self.mediaNameLab.font = [UIFont systemFontOfSize:mediaNameFontSize];
        self.mediaNameLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.mediaNameLab.numberOfLines = 0;
        self.mediaNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.mediaNameLab];
    }
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMRecommendCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:collectionViewIdentifier forIndexPath:indexPath];
    
    LMArticleSimple* lmArticleSimple = [self.dataArray objectAtIndex:indexPath.row];
    
    NSArray* arr = lmArticleSimple.pics;
    NSString* imgStr = @"";
    for (LMTextPicVideo* video in arr) {
        if (video.type == 1 && video.url.length > 0) {
            imgStr = video.url;
            break;
        }
    }
    UIImage* placeholderImage = [UIImage imageNamed:@"defaultFailedImage"];
    if (imgStr.length > 0) {
        [cell.contentIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:placeholderImage];
    }else {
        cell.contentIV.image = placeholderImage;
    }
    cell.nameLab.text = lmArticleSimple.title;
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemBlock) {
        self.itemBlock(indexPath.row);
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(recommendCollectionViewHeight, recommendCollectionViewHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}


-(void)setupContentWithModel:(LMRecommendModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.titleLab.text = model.title;
    self.titleLab.frame = CGRectMake(10, 10, screenWidth - contentIVWidth - spaceX * 3, model.titleHeight);
    
    if (model.brief != nil && model.brief.length > 0) {
        self.detailLab.text = model.brief;
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + spaceX, self.titleLab.frame.size.width, model.briefHeight);
    }else {
        self.detailLab.text = @"";
        self.detailLab.frame = CGRectMake(spaceX, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, self.titleLab.frame.size.width, 0);
    }
    
    [self.dataArray removeAllObjects];
    
    LMZhuanTi* zhuanTi = model.zt;
    NSArray* arr = zhuanTi.list;
    if (arr != nil && arr.count > 0) {
        [self.dataArray addObjectsFromArray:arr];
        
        self.collectionView.frame = CGRectMake(0, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, screenWidth, model.collectionViewHeight);
    }else {
        self.collectionView.frame = CGRectMake(0, self.detailLab.frame.origin.y + self.detailLab.frame.size.height + 10, screenWidth, 0);
    }
    [self.collectionView reloadData];
    
    self.mediaNameLab.hidden = YES;
    if (model.showMediaName) {
        self.mediaNameLab.hidden = NO;
        self.mediaNameLab.text = model.mediaName;
        self.mediaNameLab.frame = CGRectMake(10, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + 10, screenWidth - 10 * 2, 20);
    }
    if (model.alreadyRead) {
        self.titleLab.textColor = [UIColor colorWithHex:alreadyReadString];
        self.detailLab.textColor = [UIColor colorWithHex:alreadyReadString];
    }else {
        self.titleLab.textColor = [UIColor blackColor];
        self.detailLab.textColor = [UIColor colorWithHex:articleDetailString];
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
