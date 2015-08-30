//
//  ObjectDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "ObjectBuyingViewController.h"
#import "MobClick.h"

@interface ObjectDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *imageScrollViewPageControl;
@property (strong, nonatomic) NSTimer *imageScrollTimer;
@property (nonatomic) NSInteger imageCount;

@property (weak, nonatomic) IBOutlet UILabel *itemNewPriceLabel; // Without ¥
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemNewPriceLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *itemOldPriceLabel; // With ¥
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemOldPriceLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;


@property (weak, nonatomic) IBOutlet UILabel *itemStoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAllStoryButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemStoryViewHeightConstraint;

@end

@implementation ObjectDetailViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"商品详情"];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resizeViewInPriceAndTitleView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareImageScrollView];
    [self preparePriceAndTitleView];
    [self prepareItemStroyView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"商品详情"];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Preparation

- (void)prepareImageScrollView {
    CGFloat imageWidth = self.imageScrollView.frame.size.width;
    CGFloat imageHeight = self.imageScrollView.frame.size.height;
    CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    self.imageCount = 4;
    NSArray *imageNames = @[@"close", @"Stars", @"arrow-forward", @"checkmark"];
    for (NSInteger idx = 0; idx < self.imageCount; idx++) {
        imageFrame.origin.x = idx * imageWidth;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.image = [UIImage imageNamed:imageNames[idx]];
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.contentSize = CGSizeMake(self.imageCount * imageWidth, 0);
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.delegate = self;
    self.imageScrollViewPageControl.currentPage = 0;
    self.imageScrollViewPageControl.numberOfPages = self.imageCount;
    
    [self addImageScrollTimer];
}

- (void)preparePriceAndTitleView {
    // Set New Price Label
    self.itemNewPriceLabel.text = @"19999";
    // Set Old Price Label
    {
        NSAttributedString *oldPriceStr = [[NSAttributedString alloc] initWithString:@"¥29999"
                                                                          attributes:@{                                                                                                           NSStrikethroughStyleAttributeName : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle)}];
        self.itemOldPriceLabel.attributedText = oldPriceStr;
    }
    // Set Item Title
    self.itemTitleLabel.text = @"Title Title Title Title Title Title Title Title Title Title Title Title Title Title";
}

- (void)prepareItemStroyView {
    // Set Item Story
    self.itemStoryLabel.text = @"故事 故事 故事 故事 故事 故事 故事 故事 故事 故事 故事";
}

#pragma mark - Resize View

- (void)resizeViewInPriceAndTitleView {
    // Reset width of ItemNewPriceLabel
    {
        CGSize size = [self.itemNewPriceLabel.text sizeWithAttributes:@{NSFontAttributeName : self.itemNewPriceLabel.font}];
        self.itemNewPriceLabelWidthConstraint.constant = size.width + 2;
    }
    // Reset width of ItemOldPriceLabel
    {
        CGSize size = [self.itemNewPriceLabel.attributedText size];
        self.itemOldPriceLabelWidthConstraint.constant = size.width;
    }
}

- (void)resizeItemStoryView:(BOOL)expend {
    // Reset height of ItemStroyView
    if (expend) {
        
    } else {
        
    }
}

#pragma mark - Seque Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showBuyingPage"]) {
        ObjectBuyingViewController *controller = (ObjectBuyingViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

#pragma mark - Inner Helper

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

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
@end
