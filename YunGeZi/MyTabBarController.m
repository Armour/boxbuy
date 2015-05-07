//
//  MyTabBarController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyTabBarController.h"
#import "MainPageViewController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

@synthesize access_token = _access_token;
@synthesize refresh_token = _refresh_token;
@synthesize expire_time = _expire_time;

- (NSString *)access_token {
    if (!_access_token) {
        _access_token = [[NSString alloc] init];
    }
    return _access_token;
}

- (void)setAccess_token:(NSString *)access_token {
    _access_token = access_token;
}

- (NSString *)refresh_token {
    if (!_refresh_token) {
        _refresh_token = [[NSString alloc] init];
    }
    return _refresh_token;
}

- (void)setRefresh_token:(NSString *)refresh_token {
    _refresh_token = refresh_token;
}

- (NSString *)expire_time {
    if (!_expire_time) {
        _expire_time = [[NSString alloc] init];
    }
    return _expire_time;
}

- (void)setExpire_time:(NSString *)expire_time {
    _expire_time = expire_time;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *selectedImage = [UIImage imageNamed:@"Main_32"];
    UIImage *unselectedImage = [UIImage imageNamed:@"Main_32"];
    UITabBarItem * item = [self.tabBar.items objectAtIndex:0];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"Menu_32"];
    unselectedImage = [UIImage imageNamed:@"Menu_32"];
    item = [self.tabBar.items objectAtIndex:1];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"Camera_32"];
    unselectedImage = [UIImage imageNamed:@"Camera_32"];
    item = [self.tabBar.items objectAtIndex:2];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"User_32"];
    unselectedImage = [UIImage imageNamed:@"User_32"];
    item = [self.tabBar.items objectAtIndex:3];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
