//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyNavigationController.h"
#import "MainPageViewController.h"
#import "ObjectDetailViewController.h"
#import "WaterfallCellView.h"
#import "WaterfallCellModel.h"
#import "AFNetworking.h"
#import "DWBubbleMenuButton.h"
#import "MobClick.h"

#define WATERFALL_CELL @"WaterfallCell"
#define HEADER_CELL @"ReusableHeaderCell"
#define ITEMS_PER_PAGE 30
#define BUBBLE_ROTATION_ANIMATION_KEY @"BubbleRotationAnimation"
#define BUBBLE_MASK_ANIMATION_KEY @"BubbleMaskAnimation"
#define BUBBLE_ANIMATION_DURATION 0.5f
#define BUBBLE_MASK_OPACITY 0.6f

@interface MainPageViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *waterfallView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) BOOL isFetching;
@property (strong, nonatomic) NSMutableArray *cellModels;
@property (strong, nonatomic) NSMutableArray *itemId;
@property (strong, nonatomic) NSMutableArray *sellerId;
@property (strong, nonatomic) NSString *choosedItemId;
@property (strong, nonatomic) NSString *choosedSellerId;
@property (strong, nonatomic) UIView *bubbleMask;
@property (strong, nonatomic) UIView *loadingMask;

@end


@implementation MainPageViewController

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
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self prepareBubbleMenu];
    [self preparePullToRefresh];
    [self prepareNavigationBar];
    [self initWaterfallView];
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

- (void)dealloc {
    self.waterfallView = nil;
}

#pragma mark - Inner Helper

- (void)initWaterfallView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.waterfallView registerClass:[WaterfallCellView class] forCellWithReuseIdentifier:WATERFALL_CELL];
    [self.waterfallView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 2;
    layout.footerHeight = 0;
    layout.headerHeight = 90;
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    self.waterfallView.collectionViewLayout = layout;

    self.isFetching = NO;

    [self addLoadingMask];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];

    [self fillCellModelsForPage:1];
}

- (void)fillCellModelsForPage:(NSUInteger)page {    // page start from 1
    if (self.isFetching || ((page > 1) && (page > self.pageCount))) {
        return;
    }
    self.isFetching = YES;
    NSLog(@"Start Fetching!!! Page: %ld", (unsigned long)page);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/searchItems"
       parameters:@{@"schoolid" : @"0",
                    @"p" : @(page),
                    @"pp" : @ITEMS_PER_PAGE}
          success:^(AFHTTPRequestOperation *operation, id response){
              //NSLog(@"JSON => %@", response);
              if (page == 1) {
                  self.pageCount = [[response valueForKeyPath:@"totalpage"] integerValue];
                  self.cellModels = [[NSMutableArray alloc] init];
                  self.itemId = [[NSMutableArray alloc] init];
                  self.sellerId = [[NSMutableArray alloc] init];
              }
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
                  [model setSellerState:@"这是毛？"];
                  [self.cellModels addObject:model];
                  [self.itemId addObject:[obj valueForKeyPath:@"Item.itemid"]];
                  [self.sellerId addObject:[obj valueForKeyPath:@"Seller.userid"]];
                  //NSLog(@" 新商品!!!! %@ ", model.itemTitle);
              }
              NSLog(@"Fetch successed!");
              [self.waterfallView reloadData];
              [self.activityIndicator stopAnimating];
              [self.activityIndicator setHidden:TRUE];
              [self removeLoadingMask];
              self.isFetching = NO;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Fetch failed...");
              self.isFetching = NO;
              [self popAlert:@"加载失败" withMessage:@"貌似网络不太好哦"];
          }];
}

- (CABasicAnimation *)prepareBubbleRotationAnimationWithFromValue:(CGFloat)fromAngle
                                                          toValue:(CGFloat)toAngle {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromAngle * (M_PI / 180.f)];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toAngle * (M_PI / 180.f)];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.duration = BUBBLE_ANIMATION_DURATION;
    rotationAnimation.repeatCount = 1;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [rotationAnimation setValue:@"BubbleRotation" forKey:BUBBLE_ROTATION_ANIMATION_KEY];
    return rotationAnimation;
}

- (CABasicAnimation *)prepareBubbleMaskAnimationWithFromValue:(CGFloat)fromOpacity
                                                      toValue:(CGFloat)toOpacity {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromOpacity];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toOpacity];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.duration = BUBBLE_ANIMATION_DURATION;
    rotationAnimation.repeatCount = 1;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [rotationAnimation setValue:@"BubbleMask" forKey:BUBBLE_MASK_ANIMATION_KEY];
    return rotationAnimation;
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
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

#pragma mark - Init Navigation Bar

- (UIBarButtonItem *)createUIBarButtonItemWithImageName:(NSString *)imageName
                                                 target:(id)target
                                                 action:(SEL)action {
    UIButton *uiBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [uiBarButton setImage:[UIImage imageNamed:imageName]
             forState:UIControlStateNormal];
    uiBarButton.tintColor = [UIColor whiteColor];
    [uiBarButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:uiBarButton];
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
                                                                      target:self
                                                                      action:@selector(performSegueToSearchPage)];
    UIBarButtonItem *notificationButton = [self createUIBarButtonItemWithImageName:@"message"
                                                                            target:self
                                                                            action:@selector(performSegueToAccountPage)]; // JUST FOR TEST
    UIBarButtonItem *configButton = [self createUIBarButtonItemWithImageName:@"config"
                                                                      target:self
                                                                      action:@selector(performSegueToUserSettingsPage)];
    NSArray *leftButtons = [NSArray arrayWithObjects:leftNavButton, leftSpaceButton, nil];
    NSArray *rightButtons = [NSArray arrayWithObjects:configButton, notificationButton, searchButton, nil];
    self.navigationItem.leftBarButtonItems = leftButtons;
    self.navigationItem.rightBarButtonItems = rightButtons;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    [titleLabel setText:@"云格子铺"];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Init Bubble Menu

- (UIButton *)createBubbleButtonWithImageName:(NSString *)imageName
                                         size:(CGSize)size
                                       target:(id)target
                                       action:(SEL)action {
    UIButton *bubbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [bubbleButton setImage:[UIImage imageNamed:imageName]
             forState:UIControlStateNormal];
    [bubbleButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    bubbleButton.layer.cornerRadius = bubbleButton.frame.size.height / 2.f;
    bubbleButton.clipsToBounds = YES;
    return bubbleButton;
}

- (void)prepareBubbleMenu {
    CGSize frameViewSize = self.view.frame.size;
    CGSize buttonSize = CGSizeMake(55.f, 55.f);
    
    UIImageView *bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                             buttonSize.width,
                                                                             buttonSize.height)];
    [bubbleImage setImage:[UIImage imageNamed:@"close"]];
    bubbleImage.layer.cornerRadius = buttonSize.height / 2.f;
    bubbleImage.clipsToBounds = YES;
    
    DWBubbleMenuButton *bubbleMenu = [[DWBubbleMenuButton alloc]
                                      initWithFrame:CGRectMake(frameViewSize.width - buttonSize.width - 40,
                                                               frameViewSize.height - buttonSize.height - 60,
                                                               buttonSize.width,
                                                               buttonSize.height)
                                      expansionDirection:DirectionUp];
    bubbleMenu.homeButtonView = bubbleImage;
    bubbleMenu.animationDuration = BUBBLE_ANIMATION_DURATION;
    
    UIButton *recycleButton = [self createBubbleButtonWithImageName:@"DefaultUserImage"
                                                               size:buttonSize
                                                             target:nil
                                                             action:nil];
    UIButton *sellButton = [self createBubbleButtonWithImageName:@"DefaultItemImage"
                                                            size:buttonSize
                                                          target:nil
                                                          action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:recycleButton, sellButton, nil];
    [bubbleMenu addButtons:buttons];
    
    bubbleMenu.delegate = self;
    [self.view addSubview:bubbleMenu];
    
    
    self.bubbleMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.bubbleMask setBackgroundColor:[UIColor whiteColor]];
    self.bubbleMask.alpha = BUBBLE_MASK_OPACITY;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellModels.count - indexPath.item < 5 && self.cellModels.count % ITEMS_PER_PAGE == 0)
        [self fillCellModelsForPage:(self.cellModels.count / ITEMS_PER_PAGE) + 1];
    WaterfallCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WATERFALL_CELL forIndexPath:indexPath];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 6.0f;
    WaterfallCellModel *model = [self.cellModels objectAtIndex:indexPath.item];
    [cell setItemOldPrice:model.itemOldPrice NewPrice:model.itemNewPrice];
    [cell setItemTitle:model.itemTitle];
    [cell setSellerName:model.sellerName];
    [cell setSellerState:model.sellerState];
    [cell setSellerPhotoWithStringAsync:[model photoPathWithSize:IMAGE_SIZE_LARGE]];
    [cell setItemImageWithStringAsync:[model imagePathWithSize:IMAGE_SIZE_LARGE] callback:^(BOOL succeeded, CGFloat width, CGFloat height) {
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
    [cell.itemImageButton addTarget:self action:@selector(itemButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.itemTitleButton addTarget:self action:@selector(itemButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sellerNameButton addTarget:self action:@selector(sellerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sellerPhotoImageButton addTarget:self action:@selector(sellerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [model setTitleHeight:cell.titleButtonHeightConstraint.constant];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == CHTCollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL forIndexPath:indexPath];
        // add ueariamge here
        reusableview = headerView;
    }
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    WaterfallCellModel *model = [self.cellModels objectAtIndex:indexPath.item];
    CGFloat itemWidth = (collectionView.frame.size.width - 30) / 2;
    CGFloat imageHight = model.imageWidth ? model.imageHeight * itemWidth / model.imageWidth : itemWidth;
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
        [self performSegueWithIdentifier:@"showObjectDetailFromMain" sender:self];
    }
}

- (void)sellerButtonTouchUpInside:(UIButton *)sender {
    WaterfallCellView *cell = (WaterfallCellView *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.waterfallView indexPathForCell:cell];
    if (indexPath != nil) {
        self.choosedSellerId = [self.sellerId objectAtIndex:indexPath.row];
        self.choosedItemId = @"";
        [self performSegueWithIdentifier:@"showObjectDetailFromMain" sender:self];
    }
}

- (void)configButtonTouchUpInside:(UIBarButtonItem *)sender {
    [self performSegueToUserSettingsPage];
}

#pragma mark - DWBubbleMenuView

- (void)bubbleMenuButtonWillExpand:(DWBubbleMenuButton *)expandableView {
    [expandableView.homeButtonView.layer addAnimation:[self prepareBubbleRotationAnimationWithFromValue:0.f
                                                                                                toValue:90.f]
                                               forKey:BUBBLE_ROTATION_ANIMATION_KEY];
    [self.view insertSubview:self.bubbleMask belowSubview:expandableView];
    [self.bubbleMask.layer addAnimation:[self prepareBubbleMaskAnimationWithFromValue:0.f
                                                                              toValue:BUBBLE_MASK_OPACITY]
                                 forKey:BUBBLE_MASK_ANIMATION_KEY];
}

- (void)bubbleMenuButtonWillCollapse:(DWBubbleMenuButton *)expandableView {
    [expandableView.homeButtonView.layer addAnimation:[self prepareBubbleRotationAnimationWithFromValue:90.f
                                                                                                toValue:0.f]
                                               forKey:BUBBLE_ROTATION_ANIMATION_KEY];
    [self.bubbleMask.layer addAnimation:[self prepareBubbleMaskAnimationWithFromValue:BUBBLE_MASK_OPACITY
                                                                              toValue:0.f]
                                 forKey:BUBBLE_MASK_ANIMATION_KEY];
}

- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView {
    [self.bubbleMask removeFromSuperview];
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
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)finishRefreshControl {
    [self fillCellModelsForPage:1];
    [self.storeHouseRefreshControl finishingLoading];
    NSLog(@"Refresh Done!");
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showObjectDetailFromMain"]) {
        if ([self.choosedItemId isEqualToString:@""]) {
            NSLog(@"%@!!!", self.choosedSellerId);
        } else if ([self.choosedSellerId isEqualToString:@""]) {
            ObjectDetailViewController *destViewController = segue.destinationViewController;
            destViewController.objectNumber = self.choosedItemId;
        }
    }
}

- (void)performSegueToSearchPage {
    NSLog(@"SEGUE TO SEARCHPAGE");
    [self performSegueWithIdentifier:@"showSearchPage" sender:self];
}

- (void)performSegueToUserSettingsPage {
    NSLog(@"SEGUE TO SETTINGSPAGE");
    [self performSegueWithIdentifier:@"showUserSettings" sender:self];
}

- (void)performSegueToAccountPage {
    NSLog(@"SEGUE TO ACCOUNTPAGE");
    [self performSegueWithIdentifier:@"showAccount" sender:self];
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end