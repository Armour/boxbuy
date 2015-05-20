//
//  ChangeNickNameViewController.m
//  YunGeZi
//
//  Created by Armour on 5/20/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ChangeNickNameViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MyNavigationController.h"

@interface ChangeNickNameViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *changeNickNameWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ChangeNickNameViewController


- (void)addIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_changeNickNameWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            MyNavigationController * nav = (MyNavigationController *)self.navigationController;
            nav.shouldUpdateWebView = TRUE;
        }
        responseCallback(@"0.0");
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/account/setname.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_changeNickNameWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addIndicator];
    [self loadWebViewRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
