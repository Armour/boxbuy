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
//@property (nonatomic) NSUInteger itemCount;
@property (nonatomic) BOOL isFetching;
@property (strong, nonatomic) NSMutableArray *cellModels;

@end


@implementation MainPageViewController

@synthesize pageCount;
//@synthesize itemCount;
@synthesize isFetching;
@synthesize cellModels;

#pragma mark - Life Cycle

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
                  [model setImageHash:[obj valueForKeyPath:@"Cover.hash"]];
                  [model setImageId:[obj valueForKeyPath:@"Item.cover"]];
                  [model setItemTitle:[obj valueForKeyPath:@"Item.title"]];
                  [model setItemOldPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.oldprice"] floatValue] / 100]];
                  [model setItemNewPrice:[NSString stringWithFormat:@"%.2f", [[obj valueForKeyPath:@"Item.price"] floatValue] / 100]];
                  [model setSellerName:[obj valueForKeyPath:@"Seller.nickname"]];
                  [model setSellerPhotoHash:[obj valueForKeyPath:@"SellerHeadIcon.hash"]];
                  [model setSellerPhotoId:[obj valueForKeyPath:@"Seller.headidconid"]];
                  [model setSellerState:@"这是毛？"];
                  [cellModels addObject:model];
              }
              NSLog(@"Fetch successed!");
              [self.waterfallView reloadSections:[NSIndexSet indexSetWithIndex:0]];
              isFetching = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Fetch failed...");
              isFetching = NO;
          }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"Item Count:  %ld", self.cellModels.count);
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
    WaterfallCellModel *model = [cellModels objectAtIndex:indexPath.item];
    [cell setItemOldPrice:model.itemOldPrice NewPrice:model.itemNewPrice];
    [cell setItemTitle:model.itemTitle];
    [cell setSellerName:model.sellerName];
    [cell setSellerState:model.sellerState];
    [cell setItemImageWithStringAsync:[model imagePathWithSize:IMAGE_SIZE_SMALL]];
    [cell setSellerPhotoWithStringAsync:[model photoPathWithSize:IMAGE_SIZE_SMALL]];
    //[cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[model imagePathWithSize:IMAGE_SIZE_SMALL]]];
    //[cell.sellerPhotoImageView sd_setImageWithURL:[NSURL URLWithString:[model photoPathWithSize:IMAGE_SIZE_SMALL]]];
    
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO
    return CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50);
    //return CGSizeMake(211, 249);
    //return [self.cellSizes[indexPath.item] CGSizeValue];
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

    [self.view addSubview:upMenuView];}

@end