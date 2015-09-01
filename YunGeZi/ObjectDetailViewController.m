//
//  ObjectDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "ObjectBuyingViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+WebCache.h"
#import "LoginInfo.h"
#import "DeviceDetect.h"
#import "MobClick.h"

#define PAGE_CONTROL_WIDTH 100
#define IOS_NEWER_OR_EQUAL_TO_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface ObjectDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollViewContainer;
@property (strong, nonatomic) UIPageControl *imageScrollViewPageControl;
@property (strong, nonatomic) NSTimer *imageScrollTimer;
@property (nonatomic) NSInteger imageCount;
@property (weak, nonatomic) IBOutlet UILabel *itemNewPriceLabel; // Without ¥
@property (weak, nonatomic) IBOutlet UILabel *itemOldPriceLabel; // With ¥
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemNewPriceLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *itemStoryView;
@property (weak, nonatomic) IBOutlet UILabel *itemStoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAllStoryButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemStoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *addCommetButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userBarButton;
@property (weak, nonatomic) IBOutlet UIButton *starBarButton;
@property (weak, nonatomic) IBOutlet UIButton *buyBarButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property (nonatomic) NSUInteger preferredFontSize;

@end

@implementation ObjectDetailViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"商品详情"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyFont];
    [self preparePriceAndTitleView];
    [self prepareSchoolAndNumber];
    [self prepareItemStroyView];
    [self prepareBarButton];
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self getItemDetail];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"商品详情"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inner Helper

- (CGSize)getSizeOfLabelWithText:(NSString*)text WithFont:(UIFont*)font constrainedToSize:(CGSize)size withLineBreakMode:(NSLineBreakMode)breakmode {
    if(IOS_NEWER_OR_EQUAL_TO_7){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil];
        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        return frame.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [text sizeWithFont:font constrainedToSize:size lineBreakMode:breakmode];
#pragma clang diagnostic pop
    }
}

#pragma mark - Prepare Scroll View

- (void)PrepareScrollView:(NSArray *)imageArray {
    CGFloat imageWidth = self.imageScrollView.frame.size.width;
    CGFloat imageHeight = self.imageScrollView.frame.size.height;
    CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageHeight);
    self.imageCount = [imageArray count];
    self.imageScrollViewPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(imageWidth/2 - PAGE_CONTROL_WIDTH/2, imageHeight * 0.9, PAGE_CONTROL_WIDTH, imageHeight * 0.05)];
    self.imageScrollViewPageControl.hidesForSinglePage = YES;
    self.imageScrollViewPageControl.numberOfPages = self.imageCount;
    self.imageScrollViewPageControl.currentPage = 0;
    [self.imageScrollViewContainer addSubview:self.imageScrollViewPageControl];
    [self.view bringSubviewToFront:self.imageScrollViewPageControl];

    for (NSInteger idx = 0; idx < self.imageCount; idx++) {
        imageFrame.origin.x = idx * imageWidth;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-md.jpg", [imageArray objectAtIndex:idx][@"imageid"], [imageArray objectAtIndex:idx][@"hash"]]]
                     placeholderImage:[UIImage imageNamed:@"default_cover"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.delegate = self;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.contentSize = CGSizeMake(self.imageCount * imageWidth, 0);
    if (self.imageCount != 0) {
        [self addImageScrollTimer];
    } else {
        imageFrame.origin.x = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setImage:[UIImage imageNamed:@"default_cover"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageScrollView addSubview:imageView];
    }
}

#pragma mark - Image Scroll Timer

- (void)imageScrollToNextImage {
    NSInteger pageNow = self.imageScrollViewPageControl.currentPage;
    NSInteger pageNext = (pageNow + 1) % self.imageCount;
    CGSize imageSize = self.imageScrollView.frame.size;
    [self.imageScrollView setContentOffset:CGPointMake(pageNext * imageSize.width, 0)
                                  animated:YES];
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

#pragma mark - Prepare Item Info

- (void)preparePriceAndTitleView {
    self.itemTitleLabel.text = @"";
    self.itemNewPriceLabel.text = @"";
    self.itemOldPriceLabel.attributedText = nil;
}

- (void)prepareSchoolAndNumber {
    self.itemNumberLabel.text = @"";
    self.schoolNameLabel.text = @"";
}

- (void)prepareItemStroyView {
    self.itemStoryLabel.text = @"";
    self.itemStoryView.layer.borderWidth = 1;
    self.itemStoryView.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.pageScrollView.contentSize = CGSizeMake(self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    self.showAllStoryButton.hidden = YES;
}

- (void)prepareShowAllStoryButton{
    CGSize maximumLabelSize = CGSizeMake(self.itemStoryLabel.bounds.size.width, 600);
    CGSize expectedLabelSize = [self getSizeOfLabelWithText:self.itemStoryLabel.text
                                                   WithFont:self.itemStoryLabel.font
                                          constrainedToSize:maximumLabelSize
                                          withLineBreakMode:self.itemStoryLabel.lineBreakMode];
    if (expectedLabelSize.height > self.itemStoryLabel.bounds.size.height + 10) {
        [self.showAllStoryButton setHidden:NO];
    }
}

- (void)prepareMyFont {
    if (IS_IPHONE_4_OR_LESS) {
        self.preferredFontSize = 13;
    } else if (IS_IPHONE_5) {
        self.preferredFontSize = 15;
    } else if (IS_IPAD) {
        self.preferredFontSize = 18;
    } else if (IS_IPHONE_6P) {
        self.preferredFontSize = 17;
    } else {
        self.preferredFontSize = 16;
    }
}

#pragma mark - Prepare Bar Button

- (void)prepareBarButton {
    [self.view layoutIfNeeded];
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.height / 2;
    self.userImageView.clipsToBounds = YES;
    [self.userNameLabel setText:@""];
    UIView *innerBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.userBarButton.frame.size.height)];
    UIView *innerBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.userBarButton.frame.size.height)];
    innerBorder1.backgroundColor = [UIColor whiteColor];
    innerBorder2.backgroundColor = [UIColor whiteColor];
    [self.starBarButton addSubview:innerBorder1];
    [self.buyBarButton addSubview:innerBorder2];
}

- (IBAction)starBarButtonTouchUpInside:(UIButton *)sender {
    [self popAlert:@"此功能后续版本开放" withMessage:@"敬请期待~"];
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
    [self.loadingMask setBackgroundColor:[UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:0.4]];
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - Resize View

- (void)resizeViewInPriceAndTitleView:(NSString *)oldPrice {
    CGSize size = [self.itemNewPriceLabel.text sizeWithAttributes:@{NSFontAttributeName : self.itemNewPriceLabel.font}];
    self.itemNewPriceLabelWidthConstraint.constant = size.width + 2;
    [self.view layoutIfNeeded];
    NSAttributedString *oldPriceStr = [[NSAttributedString alloc] initWithString:oldPrice
                                                                      attributes:@{
                                    NSStrikethroughStyleAttributeName : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle),
                                    NSFontAttributeName : [UIFont systemFontOfSize:self.preferredFontSize - 4],
                                    NSForegroundColorAttributeName : [UIColor blackColor]
                                }];
    self.itemOldPriceLabel.attributedText = oldPriceStr;
}

- (IBAction)resuzeItemStoryView:(UIButton *)sender {
    CGSize maximumLabelSize = CGSizeMake(self.itemStoryLabel.bounds.size.width, 600);
    CGSize expectedLabelSize = [self getSizeOfLabelWithText:self.itemStoryLabel.text
                                                   WithFont:self.itemStoryLabel.font
                                          constrainedToSize:maximumLabelSize
                                          withLineBreakMode:self.itemStoryLabel.lineBreakMode];
    expectedLabelSize.height += 10;
    NSInteger offset = expectedLabelSize.height - self.itemStoryLabel.bounds.size.height;
    if (offset > 0) {
        self.pageScrollView.contentSize = CGSizeMake(self.pageScrollView.contentSize.width,
                                                     self.pageScrollView.contentSize.height + offset);
        self.itemStoryViewHeightConstraint.constant = expectedLabelSize.height + 6;
        [self.showAllStoryButton setHidden:YES];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Get Item Detail

- (void)getItemDetail {
    [self addLoadingMask];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/getItemDetail"
       parameters:@{@"itemid" : self.objectNumber,
                    @"schoolid" : [LoginInfo sharedInfo].schoolId}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //Label
              [self.itemTitleLabel setText:[responseObject valueForKeyPath:@"Item.title"]];
              [self.itemStoryLabel setText:[responseObject valueForKeyPath:@"Item.content"]];
              [self.itemNumberLabel setText:[responseObject valueForKeyPath:@"Item.amount"]];
              [self.userNameLabel setText:[responseObject valueForKeyPath:@"Seller.nickname"]];
              //ScrollView
              [self PrepareScrollView:[responseObject valueForKeyPath:@"Images"]];
              [self prepareShowAllStoryButton];
              // Price and Resize
              [self.itemNewPriceLabel setText:[NSString stringWithFormat:@"%.1f", [[responseObject valueForKeyPath:@"Item.price"] floatValue] / 100]];
              [self.itemNewPriceLabel setFont:[UIFont systemFontOfSize:self.preferredFontSize]];
              if ([responseObject valueForKeyPath:@"Item.price"] != [responseObject valueForKeyPath:@"Item.oldprice"]) {
                  NSString *tmpStr = [[NSString alloc] initWithFormat:@"¥%@", [NSString stringWithFormat:@"%.1f", [[responseObject valueForKeyPath:@"Item.oldprice"] floatValue] / 100]];
                  [self resizeViewInPriceAndTitleView:tmpStr];
              }
              //School and Location
              [self.schoolNameLabel setText:[self getSchoolNameWithId:[responseObject valueForKeyPath:@"Item.schoolid"]
                                                         withLocation:[responseObject valueForKeyPath:@"Item.location"]]];
              //Avatar
              [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-md.jpg", [responseObject valueForKeyPath:@"Seller.headiconid"], [responseObject valueForKeyPath:@"SellerHeadIcon.hash"]]]
                                                         placeholderImage:[UIImage imageNamed:@"default_headicon"]];
              [self removeLoadingMask];
              [self.activityIndicator stopAnimating];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"网络不好" withMessage:@"请稍后重试~"];
              [self.navigationController popViewControllerAnimated:YES];
              [self removeLoadingMask];
              [self.activityIndicator stopAnimating];
          }];
}

#pragma mark - Get School Name

- (NSString *)getSchoolNameWithId:(NSString *)schoolid withLocation:(NSString *)location {
    NSString *tmpStr = [[NSString  alloc] initWithFormat:@"%@%@", [[LoginInfo sharedInfo] schoolNameWithSchoolId:schoolid]
                                       ,[[LoginInfo sharedInfo] locationNameWithSchoolId:schoolid withLocationId:location]];
    return tmpStr;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView) {
        CGFloat imageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / imageWidth + 0.5;
        self.imageScrollViewPageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.imageScrollView) {
        [self removeImageScrollTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.imageScrollView) {
        [self addImageScrollTimer];
    }
}

#pragma mark - Go To Buying Page

- (IBAction)buyingButtonTouchUpInside:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showBuyingPage" sender:self];
}

#pragma mark - Add Comment

- (IBAction)commetButtonTouchUpInside:(UIButton *)sender {
    [self popAlert:@"暂不支持评论" withMessage:@"下版本开放此功能, 往少侠见谅>.<"];
}

#pragma mark - Seque Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showBuyingPage"]) {
        ObjectBuyingViewController *controller = (ObjectBuyingViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
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
