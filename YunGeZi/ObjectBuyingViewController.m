//
//  ObjectBuyInMainViewController.m
//  YunGeZi
//
//  Created by Armour on 5/10/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectBuyingViewController.h"
#import "ObjectBuyingResultViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface ObjectBuyingViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectBuyWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property WebViewJavascriptBridge* bridge;

@end


@implementation ObjectBuyingViewController

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectBuyWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self performSegueWithIdentifier:@"showBuyingResult" sender:self];
        }
        responseCallback(self.objectNumber);
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.uboxs.com/trades/confirm.html?item_id=%@&access_token=%@&school_id=%@", self.objectNumber, [LoginInfo sharedInfo].accessToken, [LoginInfo sharedInfo].schoolId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectBuyWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self addWebViewBridge];
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
    [MobClick beginLogPageView:@"购买页面"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"购买页面"];
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
