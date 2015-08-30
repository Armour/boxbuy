//
//  RecycleViewController.m
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "RecycleViewController.h"
#import "MobClick.h"

@interface RecycleViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *orderWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation RecycleViewController

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)loadWebViewRequest {
    self.orderWebView.delegate = self;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.uboxs.com/huisou.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_orderWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
    [self loadWebViewRequest];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"添加回收"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"添加回收"];
}

@end
