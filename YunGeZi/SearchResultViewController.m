//
//  SearchInCategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ObjectDetailViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"

@interface SearchResultViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *searchResultWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property WebViewJavascriptBridge* bridge;

@end


@implementation SearchResultViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
    [self addWebViewBridge];
    [self loadWebViewRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"搜索结果"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索结果"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Webview Bridge

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.searchResultWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        self.objectNumber = data;
        [self performSegueWithIdentifier:@"showObjectDetailFromSearch" sender:self];
        responseCallback(self.objectNumber);
    }];
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

#pragma mark - Web Request

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool_1_3.html?q=%@", self.searchQuery];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [self.searchResultWebView loadRequest:request];
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showObjectDetailFromSearch"]) {
        ObjectDetailViewController *controller = (ObjectDetailViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

@end
