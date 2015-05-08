//
//  OrderViewController.m
//  YunGeZi
//
//  Created by Armour on 5/8/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "OrderViewController.h"

@interface OrderViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *orderWebView;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/account/order.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_orderWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
