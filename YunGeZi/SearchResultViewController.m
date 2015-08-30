//
//  SearchInCategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ObjectDetailViewController.h"
#import "WaterfallCellView.h"
#import "WaterfallCellModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "MyButton.h"
#import "MobClick.h"
#import "LoginInfo.h"

#define WATERFALL_CELL @"WaterfallCell"
#define ITEMS_PER_PAGE 20
#define PAGE_CONTROL_WIDTH 100
#define LABEL_FONT_SIZE 12
#define USER_NAME_FONT_SIZE 10
#define ROW_PADDING (self.view.bounds.size.width / 60)
#define SELLER_INTRO_DEFAULT @"加载中..."
#define SELLER_INTRO_FAIL @"加载失败..请刷新重试"

@interface SearchResultViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *waterfallView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *cellModels;
@property (strong, nonatomic) NSMutableArray *itemId;
@property (strong, nonatomic) NSMutableArray *sellerId;
@property (strong, nonatomic) NSString *choosedItemId;
@property (strong, nonatomic) NSString *choosedSellerId;
@property (strong, nonatomic) UIView *loadingMask;
@property (nonatomic) NSInteger imageCount;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) BOOL isFetching;

@end


@implementation SearchResultViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self preparePullToRefresh];
    [self prepareViewStatus];
    [self initWaterfallView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"搜索结果"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索结果"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [LoginInfo sharedInfo].searchViewIsDisappeared = YES;
}

- (void)dealloc {
    [self.waterfallView setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inner Helper

- (void)initWaterfallView {
    [self.waterfallView registerClass:[WaterfallCellView class] forCellWithReuseIdentifier:WATERFALL_CELL];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 2;
    layout.minimumColumnSpacing = ROW_PADDING;
    layout.minimumInteritemSpacing = ROW_PADDING;
    layout.sectionInset = UIEdgeInsetsMake(ROW_PADDING, ROW_PADDING, ROW_PADDING, ROW_PADDING);
    self.waterfallView.collectionViewLayout = layout;
    self.isFetching = NO;
    [self addLoadingMask];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self fillCellModelsForPage:1];
}

- (void)fillCellModelsForPage:(NSUInteger)page {    // page start from 1
    if (self.isFetching || ((page > 1) && (page > self.pageCount))) {
        return;
    }
    self.isFetching = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/searchItems"
       parameters:@{@"q" : self.searchQuery,
                    @"schoolid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"],
                    @"p" : @(page),
                    @"pp" : @ITEMS_PER_PAGE}
          success:^(AFHTTPRequestOperation *operation, id response){
              if ([LoginInfo sharedInfo].searchViewIsDisappeared) return;
              if ([[response valueForKeyPath:@"total"] isEqual:@0]) {
                  [self popAlert:@"没有找到商品" withMessage:@"换一个关键词吧亲w"];
                  [self.navigationController popViewControllerAnimated:YES];
              }
              if (page == 1) {
                  self.pageCount = [[response valueForKeyPath:@"totalpage"] integerValue];
                  self.cellModels = [[NSMutableArray alloc] init];
                  self.itemId = [[NSMutableArray alloc] init];
                  self.sellerId = [[NSMutableArray alloc] init];
              }
              int indexPath = 0;
              for (id obj in [response valueForKeyPath:@"result"]) {
                  WaterfallCellModel *model = [[WaterfallCellModel alloc] init];
                  [model setImageWidth:200];
                  [model setImageHeight:200];
                  [model setImageHash:[obj valueForKeyPath:@"Cover.hash"]];
                  [model setImageId:[obj valueForKeyPath:@"Item.cover"]];
                  [model setItemTitle:[obj valueForKeyPath:@"Item.title"]];
                  [model setItemOldPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.oldprice"] floatValue] / 100]];
                  [model setItemNewPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.price"] floatValue] / 100]];
                  [model setSellerName:[obj valueForKeyPath:@"Seller.nickname"]];
                  [model setSellerPhotoHash:[obj valueForKeyPath:@"SellerHeadIcon.hash"]];
                  [model setSellerPhotoId:[obj valueForKeyPath:@"Seller.headiconid"]];
                  [model setSellerIntro: [obj valueForKeyPath:@"Seller.intro"]];
                  [self.cellModels addObject:model];
                  [self.itemId addObject:[obj valueForKeyPath:@"Item.itemid"]];
                  [self.sellerId addObject:[obj valueForKeyPath:@"Seller.userid"]];
                  indexPath++;
              }
              NSLog(@"Fetch successed!");
              [self.waterfallView reloadData];
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
              self.isFetching = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Fetch failed...");
              if ([LoginInfo sharedInfo].searchViewIsDisappeared) return;
              self.isFetching = NO;
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
              [self popAlert:@"加载失败" withMessage:@"貌似网络不太好哦"];
              [self.navigationController popViewControllerAnimated:YES];
          }];
}

#pragma mark - Prepare Notification

- (void)prepareViewStatus {
    [LoginInfo sharedInfo].searchViewIsDisappeared = NO;
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![LoginInfo sharedInfo].searchViewIsDisappeared) {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![LoginInfo sharedInfo].searchViewIsDisappeared) {
        [self.storeHouseRefreshControl scrollViewDidEndDragging];
    }
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.00]];
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellModels.count - indexPath.item < 5 && self.cellModels.count % ITEMS_PER_PAGE == 0) {
        [self fillCellModelsForPage:(self.cellModels.count / ITEMS_PER_PAGE) + 1];
    }
    WaterfallCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WATERFALL_CELL forIndexPath:indexPath];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 6.0f;
    WaterfallCellModel *model = [self.cellModels objectAtIndex:indexPath.item];
    [cell setItemOldPrice:model.itemOldPrice NewPrice:model.itemNewPrice];
    [cell setItemTitle:model.itemTitle];
    [cell setSellerName:model.sellerName];
    [cell setSellerIntro:model.sellerIntro];
    [cell setSellerPhotoWithStringAsync:[model photoPathWithSize:IMAGE_SIZE_MEDIUM]];
    __weak SearchResultViewController *weakSelf = self;
    [cell setItemImageWithStringAsync:[model imagePathWithSize:IMAGE_SIZE_MEDIUM]
                         withWeakSelf:weakSelf
                        withIndexPath:indexPath
                             callback:^(BOOL succeeded, CGFloat width, CGFloat height, NSIndexPath *indexPath, id weakSelf) {
                                 if (succeeded) {
                                     if (![LoginInfo sharedInfo].searchViewIsDisappeared) {
                                         [UIView setAnimationsEnabled:NO];
                                         SearchResultViewController *tmpSelf = weakSelf;
                                         [tmpSelf.waterfallView performBatchUpdates:^{
                                             WaterfallCellModel *weakModel = [tmpSelf.cellModels objectAtIndex:indexPath.item];
                                             [weakModel setImageWidth:width];
                                             [weakModel setImageHeight:height];
                                             [tmpSelf.waterfallView reloadItemsAtIndexPaths:@[indexPath]];
                                         } completion:^(BOOL finished) {
                                             [UIView setAnimationsEnabled:YES];
                                         }];
                                     }
                                 }
                             }];
    [cell.itemImageButton addTarget:self action:@selector(itemButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.itemTitleButton addTarget:self action:@selector(itemButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sellerNameButton addTarget:self action:@selector(sellerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sellerPhotoImageButton addTarget:self action:@selector(sellerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [model setTitleHeight:cell.titleButtonHeightConstraint.constant];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    WaterfallCellModel *model = [self.cellModels objectAtIndex:indexPath.item];
    CGFloat itemWidth = (collectionView.frame.size.width - ROW_PADDING * 3) / 2;
    CGFloat imageHight = model.imageWidth ? model.imageHeight * itemWidth / model.imageWidth : itemWidth;
    if (imageHight < itemWidth * 0.8)
        imageHight = itemWidth * 0.8;
    CGFloat itemHeight = imageHight + model.titleHeight + 88;
    CGSize  itemsize = CGSizeMake(itemWidth, itemHeight);
    return itemsize;
}

#pragma mark - Button Touch Event Handle

- (void)itemButtonTouchUpInside:(UIButton *)sender {
    WaterfallCellView *cell = (WaterfallCellView *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.waterfallView indexPathForCell:cell];
    if (indexPath != nil) {
        self.choosedItemId = [self.itemId objectAtIndex:indexPath.item];
        self.choosedSellerId = @"";
        //[self performSegueWithIdentifier:@"showObjectDetailFromMain" sender:self];
    }
}

- (void)sellerButtonTouchUpInside:(UIButton *)sender {
    WaterfallCellView *cell = (WaterfallCellView *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.waterfallView indexPathForCell:cell];
    if (indexPath != nil) {
        self.choosedSellerId = [self.sellerId objectAtIndex:indexPath.row];
        self.choosedItemId = @"";
        //[self performSegueWithIdentifier:@"showObjectDetailFromMain" sender:self];
    }
}

#pragma mark - Pull To Refresh

- (void)preparePullToRefresh {
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.waterfallView
                                                                            target:self
                                                                     refreshAction:@selector(pullToRefreshTriggered:)
                                                                             plist:@"boxbuy"
                                                                             color:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]
                                                                         lineWidth:2
                                                                        dropHeight:70
                                                                             scale:0.8
                                                              horizontalRandomness:300
                                                           reverseLoadingAnimation:NO
                                                           internalAnimationFactor:0.5];
}

#pragma mark - Listening for the user to trigger a refresh

- (void)pullToRefreshTriggered:(id)sender {
    NSLog(@"Refresh~!");
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)finishRefreshControl {
    [self fillCellModelsForPage:1];
    [self.storeHouseRefreshControl finishingLoading];
    NSLog(@"Refresh Done!");
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if([segue.identifier isEqualToString:@"showObjectDetailFromSearch"]) {
        //ObjectDetailViewController *controller = (ObjectDetailViewController *)segue.destinationViewController;
        //[controller setObjectNumber:self.objectNumber];
    //}
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
