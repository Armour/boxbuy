//
//  OrderViewController.m
//  YunGeZi
//
//  Created by Armour on 5/8/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "OrderViewController.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface OrderViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *orderWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;

@end


@implementation OrderViewController

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)loadWebViewRequest {
    self.orderWebView.delegate = self;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.uboxs.com/account/order.html?access_token=%@", [LoginInfo sharedInfo].accessToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_orderWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareLoadingMask];
    [self prepareMyIndicator];
    [self loadWebViewRequest];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self addLoadingMask];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    [self removeLoadingMask];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self removeLoadingMask];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的订单"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的订单"];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.5;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

@end
