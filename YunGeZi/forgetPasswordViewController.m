//
//  forgetPasswordViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "forgetPasswordViewController.h"

@interface forgetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *forgetPasswordWebView;

@end

@implementation forgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/forget.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_forgetPasswordWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
