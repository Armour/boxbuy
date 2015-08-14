//
//  RootViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "RootViewController.h"
#import "LeftMenuTreeViewModel.h"

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
    [self PostLoginTokenToLeftMenu];
    // Do any additional setup after loading the view.
}

- (void)PostLoginTokenToLeftMenu {
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObjectsAndKeys:self.accessToken, @"accessToken", self.refreshToken, @"refreshToken", self.expireTime, @"expireTime", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostLoingTokenFromRootToLeftMenu" object:self userInfo:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
