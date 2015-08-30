//
//  ChangeNickNameViewController.m
//  YunGeZi
//
//  Created by Armour on 5/20/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ChangeNickNameViewController.h"
#import "MyNavigationController.h"
#import "MobClick.h"

@interface ChangeNickNameViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;

@end


@implementation ChangeNickNameViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"修改昵称"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"修改昵称"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare Activity Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.4;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

@end
