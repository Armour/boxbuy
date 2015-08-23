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
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "MobClick.h"

#define WATERFALL_CELL @"WaterfallCell"
#define HEADER_CELL @"ReusableHeaderCell"
#define ITEMS_PER_PAGE 30
#define PAGE_CONTROL_WIDTH 100
#define LABEL_FONT_SIZE 12
#define USER_NAME_FONT_SIZE 10
#define ROW_PADDING (self.view.bounds.size.width / 60)
#define HEADER_HEIGHT (GALLERY_HEIGHT + HOTUSER_HEIGHT + ROW_PADDING)
#define GALLERY_HEIGHT (self.view.bounds.size.height * 0.25)
#define HOTUSER_WIDTH ((self.view.bounds.size.width - 5 * ROW_PADDING) * 0.2)
#define HOTUSER_PADDING HOTUSER_WIDTH * 0.1
#define HOTUSER_HEIGHT (HOTUSER_WIDTH + HOTUSER_PADDING * 3)
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
@property (strong, nonatomic) UIView *hottestUserView;
@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) UIPageControl *imageScrollViewPageControl;
@property (strong, nonatomic) NSTimer *imageScrollTimer;
@property (nonatomic) NSInteger imageCount;

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
    [self prepareNavigationBar];
    [self prepareLoadingMask];
    [self preparePullToRefresh];
    [self prepareImageScrollView];
    [self prepareHottestUserView];
    [self initWaterfallView];
    [self prepareBubbleMenu];
    [self prepareMyNotification];
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
    [self.waterfallView registerClass:[WaterfallCellView class] forCellWithReuseIdentifier:WATERFALL_CELL];
    [self.waterfallView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 2;
    layout.footerHeight = 0;
    layout.headerHeight = HEADER_HEIGHT;
    layout.minimumColumnSpacing = ROW_PADDING;
    layout.minimumInteritemSpacing = ROW_PADDING;
    layout.sectionInset = UIEdgeInsetsMake(ROW_PADDING, ROW_PADDING, ROW_PADDING/2, ROW_PADDING);
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

#pragma mark - Prepare Notification 

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performSegueToAccountPage)
                                                 name:@"SideMenuToAccountInfo"
                                               object:nil];
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - Prepare ImageScrollView

- (void)prepareImageScrollView {
    CGFloat imageWidth = self.view.frame.size.width;
    CGRect imageFrame = CGRectMake(0, 0, imageWidth, GALLERY_HEIGHT);
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:imageFrame];
    self.imageScrollViewPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(imageWidth/2 - PAGE_CONTROL_WIDTH/2, GALLERY_HEIGHT * 0.9 - ROW_PADDING, PAGE_CONTROL_WIDTH, ROW_PADDING)];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://v2.api.boxbuy.cc/getExhibitions"
      parameters:@{@"exhibition_group_id":@"index_school_header_1",
                   @"school_id"          :@1,
                   @"json"               :@"true"}
         success:^(AFHTTPRequestOperation *operation, id response) {
             int count = 0;
             CGRect imageFrame = CGRectMake(0, 0, imageWidth, GALLERY_HEIGHT);
             for (id obj in response) {
                 imageFrame.origin.x = count++ * imageWidth;
                 UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
                 [imageView sd_setImageWithURL:[obj valueForKeyPath:@"image_url"] placeholderImage:[UIImage imageNamed:@"default_cover"]];
                 [self.imageScrollView addSubview:imageView];
             }
             self.imageCount = count;
             self.imageScrollView.showsHorizontalScrollIndicator = NO;
             self.imageScrollView.showsVerticalScrollIndicator = NO;
             self.imageScrollView.contentSize = CGSizeMake(self.imageCount * imageWidth, 0);
             self.imageScrollView.pagingEnabled = YES;
             self.imageScrollView.delegate = self;
             self.imageScrollViewPageControl.numberOfPages = self.imageCount;
             self.imageScrollViewPageControl.currentPage = 0;
             [self addImageScrollTimer];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self prepareImageScrollView];
             NSLog(@"Gallary Fail!!! Retry!!");
         }];
}

- (void)imageScrollToNextImage {
    NSInteger pageNow = self.imageScrollViewPageControl.currentPage;
    NSInteger pageNext = (pageNow + 1) % self.imageCount;
    CGSize imageSize = self.imageScrollView.frame.size;
    [self.imageScrollView setContentOffset:CGPointMake(pageNext * imageSize.width, 0) animated:YES];
}

- (void)addImageScrollTimer {
    self.imageScrollTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                             target:self
                                                           selector:@selector(imageScrollToNextImage)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)removeImageScrollTimer {
    [self.imageScrollTimer invalidate];
}

#pragma mark - Prepare HottestUserView

- (void)prepareHottestUserView {
    CGRect imageFrame = CGRectMake(ROW_PADDING, GALLERY_HEIGHT + ROW_PADDING, self.view.frame.size.width - ROW_PADDING * 2, HOTUSER_HEIGHT);
    self.hottestUserView = [[UIView alloc] initWithFrame:imageFrame];
    self.hottestUserView.backgroundColor = [UIColor whiteColor];
    self.hottestUserView.layer.borderWidth = 1;
    self.hottestUserView.layer.borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.00].CGColor;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://v2.api.boxbuy.cc/getAccountsHottest"
      parameters:@{@"schoolid" : @1,
                   @"json"     : @"true"}
         success:^(AFHTTPRequestOperation *operation, id response) {
             int count = 0;
             for (id obj in response) {
                 if (count >= 5)
                     break;
                 //[obj valueForKeyPath:@"Account.userid"];
                 NSString *imagePath = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-%@.jpg", [obj valueForKeyPath:@"Account.headiconid"], [obj valueForKeyPath:@"HeadIcon.hash"], @"ori"];
                 NSURL *imageUrl = [NSURL URLWithString:imagePath];
                 // Image Button
                 UIButton *hottestUserImageButton = [[UIButton alloc] initWithFrame:CGRectMake(count * HOTUSER_WIDTH + HOTUSER_PADDING, HOTUSER_PADDING, HOTUSER_WIDTH - HOTUSER_PADDING * 2, HOTUSER_WIDTH - HOTUSER_PADDING * 2)];
                 [hottestUserImageButton sd_setBackgroundImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_headicon"]];
                 hottestUserImageButton.layer.cornerRadius = hottestUserImageButton.bounds.size.height / 2.f;
                 hottestUserImageButton.clipsToBounds = YES;
                 [self.hottestUserView addSubview:hottestUserImageButton];
                 // Name Button
                 UIButton *hottestUserNameButton = [[UIButton alloc] initWithFrame:CGRectMake(count * HOTUSER_WIDTH, HOTUSER_WIDTH, HOTUSER_WIDTH, HOTUSER_PADDING * 2)];
                 [hottestUserNameButton.titleLabel setFont:[UIFont systemFontOfSize:USER_NAME_FONT_SIZE]];
                 [hottestUserNameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                 [hottestUserNameButton setTitle:[obj valueForKeyPath:@"Account.nickname"] forState:UIControlStateNormal];
                 [self.hottestUserView addSubview:hottestUserNameButton];
                 count++;
             }
             UILabel *hottestUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - ROW_PADDING * 5, 0, ROW_PADDING * 2, HOTUSER_HEIGHT)];
             hottestUserLabel.textColor = [UIColor blackColor];
             hottestUserLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:LABEL_FONT_SIZE];
             hottestUserLabel.text = @"热门格主";
             hottestUserLabel.lineBreakMode = NSLineBreakByCharWrapping;
             hottestUserLabel.numberOfLines = 0;
             [self.hottestUserView addSubview:hottestUserLabel];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self prepareHottestUserView];
             NSLog(@"Hottest User Fail!!! Retry!!");
         }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView) {
        CGFloat imageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / imageWidth + 0.5;
        self.imageScrollViewPageControl.currentPage = page;
    } else {
        [self.storeHouseRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView) {
        [self removeImageScrollTimer];
    } else {
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.imageScrollView) {
        [self addImageScrollTimer];
    } else {
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
    CGSize buttonSize = CGSizeMake(frameViewSize.width / 6, frameViewSize.width / 6);
    
    UIImageView *bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                             buttonSize.width,
                                                                             buttonSize.height)];
    [bubbleImage setImage:[UIImage imageNamed:@"guide_entry"]];
    bubbleImage.layer.cornerRadius = buttonSize.height / 2.f;
    bubbleImage.clipsToBounds = YES;
    
    DWBubbleMenuButton *bubbleMenu = [[DWBubbleMenuButton alloc]
                                      initWithFrame:CGRectMake(frameViewSize.width * 0.9 - buttonSize.width,
                                                               frameViewSize.height * 0.89 - buttonSize.height,
                                                               buttonSize.width,
                                                               buttonSize.height)
                                      expansionDirection:DirectionUp];
    bubbleMenu.homeButtonView = bubbleImage;
    bubbleMenu.animationDuration = BUBBLE_ANIMATION_DURATION;
    
    UIButton *recycleButton = [self createBubbleButtonWithImageName:@"guide_entry_recycle"
                                                               size:buttonSize
                                                             target:nil
                                                             action:nil];
    UIButton *sellButton = [self createBubbleButtonWithImageName:@"guide_entry_upload"
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
        [headerView addSubview:self.imageScrollView];
        [headerView addSubview:self.imageScrollViewPageControl];
        [headerView bringSubviewToFront:self.imageScrollViewPageControl];
        [headerView addSubview:self.hottestUserView];
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
    CGFloat itemWidth = (collectionView.frame.size.width - ROW_PADDING * 3) / 2;
    CGFloat imageHight = model.imageWidth ? model.imageHeight * itemWidth / model.imageWidth : itemWidth;
    if (imageHight < itemWidth * 0.7)
        imageHight = itemWidth * 0.7;
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