//
//  LMExploreViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/5/3.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMExploreViewController.h"
#import "LMExploreTitleCollectionViewCell.h"
#import "LMExploreDetailViewController.h"
#import "LMHomeRightBarButtonItemView.h"
#import "LMMyMessageViewController.h"
#import "LMHomeNavigationBarView.h"
#import "LMTool.h"

@interface LMExploreViewController () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) LMHomeNavigationBarView* naviBarView;
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation LMExploreViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    CGFloat statusBarHeight = 20;
    if ([LMTool isIPhoneX]) {
        statusBarHeight = 44;
    }
    self.naviBarView = [[LMHomeNavigationBarView alloc]init];
    [self.view addSubview:self.naviBarView];
    
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.naviBarView.frame.size.height - statusBarHeight)];
    navTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    navTitleLabel.textColor = [UIColor colorWithHex:themeOrangeString];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.text = @"探索";
    [self.naviBarView addSubview:navTitleLabel];
    navTitleLabel.center = CGPointMake(self.naviBarView.frame.size.width / 2, self.naviBarView.frame.size.height / 2 + statusBarHeight / 2);
    
    __weak LMExploreViewController* weakSelf = self;
    
    LMHomeRightBarButtonItemView* rightItem = [[LMHomeRightBarButtonItemView alloc]init];
    rightItem.clickBlock = ^(BOOL didClick) {
        LMMyMessageViewController* messageVC = [[LMMyMessageViewController alloc]init];
        [weakSelf.navigationController pushViewController:messageVC animated:YES];
    };
    [self.naviBarView addSubview:rightItem];
    rightItem.center = CGPointMake(self.naviBarView.frame.size.width - 30, navTitleLabel.center.y);
    
    self.currentIndex = 0;
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"娱乐", @"奇闻", @"奇史", @"段子", nil];
    
    //collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.naviBarView.frame.origin.y + self.naviBarView.frame.size.height, self.view.frame.size.width, 30) collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMExploreTitleCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.collectionView];
    
    //scrollView
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.collectionView.frame.origin.y - self.collectionView.frame.size.height)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.titleArray.count, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view insertSubview:self.scrollView belowSubview:self.collectionView];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    LMExploreDetailViewController* exploreDetailVC = [[LMExploreDetailViewController alloc]init];
    exploreDetailVC.currentType = self.currentIndex;
    [self addChildViewController:exploreDetailVC];
    [self.scrollView addSubview:exploreDetailVC.view];
    exploreDetailVC.view.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMExploreTitleCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString* str = [self.titleArray objectAtIndex:indexPath.row];
    cell.nameLab.text = str;
    if (self.currentIndex == indexPath.row) {
        [cell setupSelected:YES];
    }else {
        [cell setupSelected:NO];
    }
    
    if (indexPath.row == self.titleArray.count - 1) {
        if (self.collectionView.contentSize.width < self.view.frame.size.width) {
            CGPoint originPoint = self.collectionView.center;
            self.collectionView.frame = CGRectMake(0, self.naviBarView.frame.origin.y + self.naviBarView.frame.size.height, self.collectionView.contentSize.width, self.collectionView.frame.size.height);
            originPoint.x = self.view.frame.size.width / 2;
            self.collectionView.center = originPoint;
        }
    }
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currentIndex = indexPath.row;
    
    //创建
    [self createExploreDetailViewController];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.currentIndex, 0);
    }];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* titleStr = [self.titleArray objectAtIndex:indexPath.row];
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:18];
    lab.text = titleStr;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];
    
    return CGSizeMake(labSize.width + 20, self.collectionView.frame.size.height);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        
        self.currentIndex = page;
        
        //
        [self createExploreDetailViewController];
    }
}

-(void)createExploreDetailViewController {
    BOOL isContain = NO;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMExploreDetailViewController class]]) {
            LMExploreDetailViewController* exploreDetailVC = (LMExploreDetailViewController* )vc;
            if (exploreDetailVC.currentType == self.currentIndex) {
                isContain = YES;
                break;
            }
        }
    }
    if (!isContain) {
        LMExploreDetailViewController* exploreDetailVC = [[LMExploreDetailViewController alloc]init];
        exploreDetailVC.currentType = self.currentIndex;
        exploreDetailVC.view.frame = CGRectMake(self.scrollView.frame.size.width * self.currentIndex, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self addChildViewController:exploreDetailVC];
        [self.scrollView addSubview:exploreDetailVC.view];
    }
    
    [self.collectionView reloadData];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
