//
//  avatarViewController.m
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AvatarViewController.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface AvatarViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation AvatarViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的头像"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
    [self showAvatar];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的头像"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibg"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - Show Avatar

- (void)showAvatar {
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.avatarImageView sd_setImageWithURL:[[NSURL alloc] initWithString:[LoginInfo sharedInfo].photoUrlOriString]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if (!image) {
                                           [self.avatarImageView setImage:[UIImage imageNamed:@"default_headicon"]];
                                       }
                                       [self.activityIndicator stopAnimating];
                                   }];
}

@end