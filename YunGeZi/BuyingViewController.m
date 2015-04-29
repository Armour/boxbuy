//
//  BuyingViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "BuyingViewController.h"
#import "MyTabBarController.h"

@interface BuyingViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *BuyingWebView;

@end

@implementation BuyingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/items/add.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_BuyingWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
