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

@end

@implementation ObjectDetailViewController

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

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"商品详情"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareImageScrollView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"商品详情"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
