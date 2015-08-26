//
//  RootViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "RootViewController.h"
#import "LeftMenuTreeViewModel.h"
#import "LoginInfo.h"

@interface RootViewController ()

@end

@implementation RootViewController

#pragma - Life Cycle

- (void)awakeFromNib {
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
    self.backgroundImage = [UIImage imageNamed:@"Stars"];
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyNotification];
    [self PostLoginTokenToLeftMenu];
}

- (void)PostLoginTokenToLeftMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostLoingTokenFromRootToLeftMenu" object:self userInfo:nil];
}

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLeftMenuView)
                                                 name:@"SideMenuToAccountInfo"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLeftMenuView)
                                                 name:@"SideMenuToChangeSchool"
                                               object:nil];
}

- (void)hideLeftMenuView {
    [self hideMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
