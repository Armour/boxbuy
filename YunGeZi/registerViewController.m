//
//  registerViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "registerViewController.h"
#import "WebViewJavascriptBridge.h"

@interface registerViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *registerWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property WebViewJavascriptBridge* bridge;

@end

@implementation registerViewController

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
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_registerWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {        if ([data isEqualToString:@"true"]) {
        [self popAlert:@"注册账户" withMessage:@"注册成功~ =w="];
        [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
    } else if ([data isEqualToString:@"false"]) {
        [self popAlert:@"注册账户" withMessage:@"注册失败..QAQ"];
        [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
    } else if ([data isEqualToString:@"back"]) {
        [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
    }
        responseCallback(@"0.0");
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/register.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_registerWebView loadRequest:request];
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

- (void) popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
