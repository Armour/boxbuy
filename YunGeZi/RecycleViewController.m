//
//  RecycleViewController.m
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "RecycleViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface RecycleViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *orderWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property WebViewJavascriptBridge* bridge;

@end

@implementation RecycleViewController

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_orderWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self popAlert:@"下单成功" withMessage:@"我们会尽快联系您~"];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([data isEqualToString:@"no_access"]) {
            [self popAlert:@"下单失败" withMessage:@"您的学校未开放此功能"];
        } else {
            [self popAlert:@"下单失败" withMessage:@"可能是网络问题，请重试"];
        }
        responseCallback(@"");
    }];
}

- (void)loadWebViewRequest {
    self.orderWebView.delegate = self;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.uboxs.com/huisou.html?access_token=%@", [LoginInfo sharedInfo].accessToken];
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
    [MobClick beginLogPageView:@"添加回收"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"添加回收"];
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

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
