//
//  ObjectBuyInCategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 5/10/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectBuyInCategoryViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ObjectBuyInCategoryViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectBuyWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectBuyInCategoryViewController

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
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectBuyWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self performSegueWithIdentifier:@"obejectBuyResultInCategory" sender:self];
        }
        responseCallback(self.objectNumber);
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/trades/confirm.html?item_id=%@", self.objectNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectBuyWebView loadRequest:request];
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
