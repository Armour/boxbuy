//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyNavigationController.h"
#import "MainPageViewController.h"
#import "WaterfallCellView.h"
#import "WaterfallCellModel.h"
#import "AFNetworking.h"

#define WATERFALL_CELL @"WaterfallCell"
#define ITEMS_PER_PAGE 30

@interface MainPageViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *waterfallView;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger itemCount;
@property (nonatomic) BOOL isFetching;
@property (strong, nonatomic) NSMutableArray *cellModels;

@end


@implementation MainPageViewController

@synthesize pageCount;
@synthesize itemCount;
@synthesize isFetching;
@synthesize cellModels;

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWaterfallView];
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
    self.waterfallView.collectionViewLayout = layout;

    isFetching = NO;
    [self fillCellModelsForPage:1];
}

- (void)fillCellModelsForPage:(NSUInteger)page {
    if (isFetching) {
        return;
    }
    isFetching = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/searchItems"
       parameters:@{@"schoolid" : @"0",
                    @"p" : @(page),
                    @"pp" : @ITEMS_PER_PAGE}
          success:^(AFHTTPRequestOperation *operation, id response){
              NSLog(@"JSON => %@", response);
              if (page == 1) {
                  self.pageCount = [[response valueForKeyPath:@"totalpage"] integerValue];
                  self.itemCount = [[response valueForKeyPath:@"total"] integerValue];
                  cellModels = [[NSMutableArray alloc] init];
              }
              for (id obj in [response valueForKeyPath:@"result"]) {
                  WaterfallCellModel *model = [[WaterfallCellModel alloc] init];
                  [model setImageHash:[obj valueForKeyPath:@"Cover.hash"]];
                  [model setImageId:[obj valueForKeyPath:@"Item.cover"]];
                  [model setItemTitle:[obj valueForKeyPath:@"Item.title"]];
                  [model setItemOldPrice:[obj valueForKeyPath:@"Item.oldprice"]];
                  [model setItemNewPrice:[obj valueForKeyPath:@"Item.price"]];
                  [model setSellerName:[obj valueForKeyPath:@"Seller.nickname"]];
                  [model setSellerPhotoHash:[obj valueForKeyPath:@"SellerHeadIcon.hash"]];
                  [model setSellerPhotoId:[obj valueForKeyPath:@"Seller.headidconid"]];
                  [model setSellerState:@"这是毛？"];
                  [cellModels addObject:model];
              }
              isFetching = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              isFetching = NO;
          }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // TODO
    return 100;
    //return self.itemCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (cellModels.count - indexPath.item < 5 && cellModels.count % ITEMS_PER_PAGE == 0) {
        [self fillCellModelsForPage:(cellModels.count / ITEMS_PER_PAGE) + 1];
    }
    WaterfallCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WATERFALL_CELL forIndexPath:indexPath];
    WaterfallCellModel *model = [cellModels objectAtIndex:indexPath.item];
    [cell setItemOldPrice:model.itemOldPrice NewPrice:model.itemNewPrice];
    [cell setItemTitle:model.itemTitle];
    [cell setSellerName:model.sellerName];
    [cell setSellerState:model.sellerState];
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO
    return CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50);
    //return CGSizeMake(211, 249);
    //return [self.cellSizes[indexPath.item] CGSizeValue];
}

@end