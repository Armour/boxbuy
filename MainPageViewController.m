//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MainPageViewController.h"
#import "MyTabBarController.h"

@interface MainPageViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *MainPageWebView;

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?access_token=%@&refresh_token=%@&expire_time=%@&login=1", tab.access_token, tab.refresh_token, tab.expire_time];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_MainPageWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
