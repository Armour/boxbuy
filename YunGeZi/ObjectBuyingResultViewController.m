//
//  ObjectBuyResultInMainViewController.m
//  YunGeZi
//
//  Created by Armour on 5/10/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectBuyingResultViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"

@interface ObjectBuyingResultViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectBuyResultWebview;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property WebViewJavascriptBridge* bridge;

@end


@implementation ObjectBuyingResultViewController

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectBuyResultWebview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        responseCallback(@"0.0");
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.uboxs.com/trades/confirmResult.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectBuyResultWebview loadRequest:request];
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
    [MobClick beginLogPageView:@"购买结果"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"购买结果"];
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
