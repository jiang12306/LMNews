//
//  LMZhuanTiDetailViewController.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMZhuanTiDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMRecommendImageTableViewCell.h"
#import "LMRecommendVideoTableViewCell.h"
#import "LMRecommendImagesTableViewCell.h"
#import "LMRecommendTextTableViewCell.h"
#import "LMTool.h"
#import "LMRecommendModel.h"
#import "LMNewsDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface LMZhuanTiDetailViewController () <UITableViewDataSource, UITableViewDelegate, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMZhuanTiDetailViewController

static NSString* imageCellIdentifier = @"imageCellIdentifier";
static NSString* videoCellIdentifier = @"videoCellIdentifier";
static NSString* imagesCellIdentifier = @"imagesCellIdentifier";
static NSString* textCellIdentifier = @"textCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* titleStr = self.zhuanTi.title;
    if (titleStr != nil && titleStr.length > 0) {
        self.title = titleStr;
    }else {
        self.title = @"专题详情";
    }
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat naviBarHeight = 64;
    if ([LMTool isIPhoneX]) {
        naviBarHeight = 88;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, screenHeight - naviBarHeight) style:UITableViewStyleGrouped];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMRecommendImageTableViewCell class] forCellReuseIdentifier:imageCellIdentifier];
    [self.tableView registerClass:[LMRecommendVideoTableViewCell class] forCellReuseIdentifier:videoCellIdentifier];
    [self.tableView registerClass:[LMRecommendImagesTableViewCell class] forCellReuseIdentifier:imagesCellIdentifier];
    [self.tableView registerClass:[LMRecommendTextTableViewCell class] forCellReuseIdentifier:textCellIdentifier];
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    CGFloat startY = 0;
    
    NSString* picStr = self.zhuanTi.pic;
    if (picStr != nil && picStr.length > 0) {
        UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10 * 2, (self.view.frame.size.width - 10 * 2) * 0.618)];
        [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultFailedImage"]];
        [headerView addSubview:iv];
        
        startY = iv.frame.origin.y + iv.frame.size.height;
    }
    NSString* briefStr = self.zhuanTi.simple;
    if (briefStr != nil && briefStr.length > 0) {
        UILabel* briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, startY + 10, self.view.frame.size.width - 10 * 2, 20)];
        briefLab.font = [UIFont systemFontOfSize:16];
        briefLab.textColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1];
        briefLab.numberOfLines = 0;
        briefLab.lineBreakMode = NSLineBreakByCharWrapping;
        briefLab.text = briefStr;
        [headerView addSubview:briefLab];
        CGSize labSize = [briefLab sizeThatFits:CGSizeMake(self.view.frame.size.width - 10 * 2, CGFLOAT_MAX)];
        briefLab.frame = CGRectMake(10, startY + 10, labSize.width, labSize.height);
        startY = briefLab.frame.origin.y + briefLab.frame.size.height + 10;
    }
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, startY);
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    self.dataArray = [NSMutableArray array];
    
    [self convertModelWithZhuanTi:self.zhuanTi];
}

-(void)convertModelWithZhuanTi:(LMZhuanTi* )zt {
    NSArray* listArr = zt.list;
    for (LMArticleSimple* articleSimple in listArr) {
        LMRecommendModel* model = [[LMRecommendModel alloc]init];
        model.alreadyRead = [[LMDatabaseTool sharedDatabaseTool]isAlreadyReadArticleWithArticleId:articleSimple.articleId];
        model.showMediaName = YES;
        model.mediaName = articleSimple.source.sourceName;
        model.brief = @"";
        model.briefHeight = 0;
        model.article = articleSimple;
        model.title = articleSimple.title;
        model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
        NSArray* picsArr = articleSimple.pics;
        if (picsArr == nil || picsArr.count == 0) {//LMRecommendTextTableViewCell
            model.cellStyle = LMRecommendTextTableViewCellStyle;
            model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
            model.cellHeight = model.titleHeight + spaceX * 2 + 30;
        }else {
            NSInteger isVideo = NO;
            NSInteger imagesCount = 0;
            NSString* briefStr = nil;
            for (LMTextPicVideo* lmTextPicVideo in picsArr) {
                NSInteger type = lmTextPicVideo.type;
                if ((briefStr == nil || briefStr.length == 0) && (lmTextPicVideo.text != nil && lmTextPicVideo.text.length > 0)) {
                    briefStr = lmTextPicVideo.text;
                }
                if (type == 2) {
                    isVideo = YES;
                    model.url = lmTextPicVideo.url;
                    break;
                }else if (type == 1) {
                    if (model.url != nil && model.url.length > 0) {
                        model.url2 = lmTextPicVideo.url;
                    }
                    if (model.url == nil || model.url.length == 0) {
                        model.url = lmTextPicVideo.url;
                    }
                    imagesCount ++;
                }
            }
            model.brief = briefStr;
            if (isVideo) {//LMRecommendVideoTableViewCell
                model.cellStyle = LMRecommendVideoTableViewCellStyle;
                model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                model.videoHeight = (self.view.frame.size.width - spaceX * 2) * 0.618;
                model.cellHeight = model.titleHeight + model.briefHeight + model.videoHeight + spaceX * 3 + 30;
            }else {
                if (imagesCount == 1) {//LMRecommendImageTableViewCell
                    model.cellStyle = LMRecommendImageTableViewCellStyle;
                    model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                    model.briefHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.brief maxWidth:(self.view.frame.size.width - contentIVWidth - spaceX * 3) maxLines:2 font:[UIFont systemFontOfSize:detailFontSize]];
                    model.cellHeight = model.titleHeight + model.briefHeight + spaceX * 3 + 30;
                    if (model.cellHeight < contentIVHeight + spaceX * 2 + 30) {
                        model.cellHeight = contentIVHeight + spaceX * 2 + 30;
                    }
                }else if (imagesCount == 0) {//LMRecommendTextTableViewCell
                    model.cellStyle = LMRecommendTextTableViewCellStyle;
                    model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                    model.cellHeight = model.titleHeight + spaceX * 2 + 30;
                }else {//LMRecommendImagesTableViewCell
                    model.cellStyle = LMRecommendImagesTableViewCellStyle;
                    model.titleHeight = [LMRecommendModel caculateRecommendImageLabelHeightWithText:model.title maxWidth:(self.view.frame.size.width - spaceX * 2) maxLines:2 font:[UIFont boldSystemFontOfSize:titleFontSize]];
                    model.imageHeight = imagesIVHeight;
                    model.cellHeight = model.titleHeight + model.imageHeight + spaceX * 3 + 30;
                }
            }
        }
        
        [self.dataArray addObject:model];
    }
    if (self.dataArray.count > 0) {
        [self.tableView reloadData];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    LMRecommendModelCellStyle cellStyle = model.cellStyle;
    if (cellStyle == LMRecommendImageTableViewCellStyle) {
        LMRecommendImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendVideoTableViewCellStyle) {
        LMRecommendVideoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendImagesTableViewCellStyle) {
        LMRecommendImagesTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:imagesCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendImagesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imagesCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }else if (cellStyle == LMRecommendTextTableViewCellStyle) {
        LMRecommendTextTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:textCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LMRecommendTextTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
        }
        [cell setupContentWithModel:model];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMNewsDetailViewController* newsDetailVC = [[LMNewsDetailViewController alloc]init];
    
    NSInteger section = indexPath.section;
    LMRecommendModel* model = [self.dataArray objectAtIndex:section];
    LMArticleSimple* articleSimple = model.article;
        newsDetailVC.newsId = articleSimple.articleId;
    [self.navigationController pushViewController:newsDetailVC animated:YES];
    
    [[LMDatabaseTool sharedDatabaseTool] setArticleWithArticleId:articleSimple.articleId isRead:YES];
    
    model.alreadyRead = YES;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView cancelNoMoreData];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self.tableView stopRefresh];
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
