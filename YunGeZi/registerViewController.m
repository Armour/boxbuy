//
//  registerViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "registerViewController.h"

@interface registerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *registerWebView;

@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"https://secure.boxbuy.cc/oauth/register?mobile=1&return=http%%3A%%2F%%2Fwebapp-ios.boxbuy.cc%%2Flogin.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_registerWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end