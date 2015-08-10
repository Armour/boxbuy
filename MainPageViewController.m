//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyNavigationController.h"
#import "MainPageViewController.h"
#import "WaterfallCellView.h"
#import "WaterfallCellModel.h"
#import "AFNetworking.h"
#import "DWBubbleMenuButton.h"
#import "MobClick.h"


#define WATERFALL_CELL @"WaterfallCell"
#define ITEMS_PER_PAGE 30

@interface MainPageViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *waterfallView;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) BOOL isFetching;
@property (strong, nonatomic) NSMutableArray *cellModels;

@end


@implementation MainPageViewController

@synthesize pageCount;
@synthesize isFetching;
@synthesize cellModels;

#pragma mark - Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"首页"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWaterfallView];
    [self prepareMenuButton];
    [self preparePullToRefresh];
    [self prepareNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"首页"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.waterfallView = nil;
    self.cellModels = nil;
}

#pragma mark - Inner Helper

- (void)initWaterfallView {
    [self.waterfallView registerClass:[WaterfallCellView class] forCellWithReuseIdentifier:WATERFALL_CELL];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 2;
    layout.footerHeight = 0;
    layout.headerHeight = 0;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    
    self.waterfallView.collectionViewLayout = layout;

    isFetching = NO;
    [self fillCellModelsForPage:1];
}

- (void)fillCellModelsForPage:(NSUInteger)page {    // page start from 1
    if (isFetching || ((page > 1) && (page > self.pageCount))) {
        return;
    }
    isFetching = YES;
    NSLog(@"Start Fetching!!! Page: %ld", page);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/searchItems"
       parameters:@{@"schoolid" : @"0",
                    @"p" : @(page),
                    @"pp" : @ITEMS_PER_PAGE}
          success:^(AFHTTPRequestOperation *operation, id response){
              //NSLog(@"JSON => %@", response);
              if (page == 1) {
                  self.pageCount = [[response valueForKeyPath:@"totalpage"] integerValue];
                  //self.itemCount = [[response valueForKeyPath:@"total"] integerValue];
                  cellModels = [[NSMutableArray alloc] init];
              }
              for (id obj in [response valueForKeyPath:@"result"]) {
                  WaterfallCellModel *model = [[WaterfallCellModel alloc] init];
                  [model setImageWidth:0];
                  [model setImageHeight:0];
                  [model setImageHash:[obj valueForKeyPath:@"Cover.hash"]];
                  [model setImageId:[obj valueForKeyPath:@"Item.cover"]];
                  [model setItemTitle:[obj valueForKeyPath:@"Item.title"]];
                  [model setItemOldPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.oldprice"] floatValue] / 100]];
                  [model setItemNewPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.price"] floatValue] / 100]];
                  [model setSellerName:[obj valueForKeyPath:@"Seller.nickname"]];
                  [model setSellerPhotoHash:[obj valueForKeyPath:@"SellerHeadIcon.hash"]];
                  [model setSellerPhotoId:[obj valueForKeyPath:@"Seller.headiconid"]];
                  [model setSellerState:@"这是毛？"];
                  [cellModels addObject:model];
                  NSLog(@" 新商品!!!! %@ ", model.itemTitle);
              }
              NSLog(@"Fetch successed!");
              [self.waterfallView reloadSections:[NSIndexSet indexSetWithIndex:0]];
              isFetching = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Fetch failed...");
              isFetching = NO;
              [self fillCellModelsForPage:page];
          }];
}

#pragma mark - Action


#pragma mark - Init Navigation Bar

- (UIBarButtonItem *)createUIBarButtonItemWithImageName:(NSString *)imageName
                                                 target:(id)target
                                                 action:(SEL)action {
    UIButton *_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_button setImage:[UIImage imageNamed:imageName]
             forState:UIControlStateNormal];
    _button.tintColor = [UIColor whiteColor];
    [_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_button];
    item.tintColor = [UIColor whiteColor];
    return item;
}


- (void)prepareNavigationBar {
    UIButton *spaceButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [spaceButton setTitle:@"" forState:UIControlStateNormal];
    UIBarButtonItem *leftSpaceButton = [[UIBarButtonItem alloc] initWithCustomView:spaceButton];
    UIBarButtonItem *leftNavButton = [self createUIBarButtonItemWithImageName:@"navicon"
                                                                          target:self
                                                                          action:@selector(presentLeftMenuViewController:)];
    UIBarButtonItem *searchButton = [self createUIBarButtonItemWithImageName:@"search"
                                                                      target:nil
                                                                      action:nil];
    UIBarButtonItem *notificationButton = [self createUIBarButtonItemWithImageName:@"message"
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *moreMenuButton = [self createUIBarButtonItemWithImageName:@"config"
                                                                        target:nil
                                                                        action:nil];
    NSArray *leftButtons = [NSArray arrayWithObjects:leftNavButton, leftSpaceButton, nil];
    NSArray *rightButtons = [NSArray arrayWithObjects:moreMenuButton, notificationButton, searchButton, nil];
    self.navigationItem.leftBarButtonItems = leftButtons;
    self.navigationItem.rightBarButtonItems = rightButtons;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    [titleLabel setText:@"云格子铺"];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (cellModels.count - indexPath.item < 5 && cellModels.count % ITEMS_PER_PAGE == 0) {
        [self fillCellModelsForPage:(cellModels.count / ITEMS_PER_PAGE) + 1];
    }
    WaterfallCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WATERFALL_CELL forIndexPath:indexPath];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 6.0f;
    WaterfallCellModel *model = [cellModels objectAtIndex:indexPath.item];
    [cell setItemOldPrice:model.itemOldPrice NewPrice:model.itemNewPrice];
    [cell setItemTitle:model.itemTitle];
    [cell setSellerName:model.sellerName];
    [cell setSellerState:model.sellerState];
    [cell setSellerPhotoWithStringAsync:[model photoPathWithSize:IMAGE_SIZE_ORIGIANL]];
    [cell setItemImageWithStringAsync:[model imagePathWithSize:IMAGE_SIZE_ORIGIANL] callback:^(BOOL succeeded, CGFloat width, CGFloat height) {
        if (succeeded) {
            [model setImageWidth:width];
            [model setImageHeight:height];
            [UIView setAnimationsEnabled:NO];
            [collectionView performBatchUpdates:^{
                 [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                 [UIView setAnimationsEnabled:YES];
            }];
        }
    }];
    [model setTitleHeight:cell.titleButtonHeightConstraint.constant];
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    WaterfallCellModel *model = [cellModels objectAtIndex:indexPath.item];
    CGFloat itemWidth = (collectionView.frame.size.width - 30) / 2;
    CGFloat imageHight = model.imageWidth ? model.imageHeight * itemWidth / model.imageWidth : 150;
    CGFloat itemHeight = imageHight + model.titleHeight + 88;
    CGSize  itemsize = CGSizeMake(itemWidth, itemHeight);
    return itemsize;
}

#pragma mark - Menu Button

- (void)prepareMenuButton {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    label.text = @"Tap";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    label.clipsToBounds = YES;

    DWBubbleMenuButton *upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - label.frame.size.width - 20.f,self.view.frame.size.height - label.frame.size.height - 20.f, label.frame.size.width, label.frame.size.height) expansionDirection:DirectionUp];
    upMenuView.homeButtonView = label;

    //[upMenuView addButtons:[self createDemoButtonArray]];

    [self.view addSubview:upMenuView];
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

#pragma mark - Notifying refresh control of scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.storeHouseRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Listening for the user to trigger a refresh

- (void)pullToRefreshTriggered:(id)sender {
    NSLog(@"Refresh~!");
    [self.waterfallView reloadData];
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:2.5 inModes:@[NSRunLoopCommonModes]];
}

- (void)finishRefreshControl {
    [self.storeHouseRefreshControl finishingLoading];
    NSLog(@"Refresh Done!");
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end