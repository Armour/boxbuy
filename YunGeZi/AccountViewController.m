//
//  AccountViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AccountViewController.h"
#import "MyTabBarController.h"
#import "WebViewJavascriptBridge.h"
#import "ShopViewController.h"
#import "MyNavigationController.h"
#import "MobClick.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *AccountWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property WebViewJavascriptBridge* bridge;
@property (strong, nonatomic) NSString *userid;

@end

@implementation AccountViewController

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
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_AccountWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        self.userid = data;
        if ([data isEqualToString:@"order"]) {
            [self performSegueWithIdentifier:@"showMyOrder" sender:self];
        } else if ([data isEqualToString:@"nickname"]){
            [self performSegueWithIdentifier:@"showChangeNickName" sender:self];
        } else {
            [self performSegueWithIdentifier:@"showMyShop" sender:self];
    }
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/account/index_1_3.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_AccountWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addIndicator];
    [self loadWebViewRequest];
}

-(void)viewDidAppear:(BOOL)animated {
    MyNavigationController * nav = (MyNavigationController *)self.navigationController;
    if (nav.shouldUpdateWebView) {
        [_AccountWebView reload];
        nav.shouldUpdateWebView = FALSE;
    }
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showMyShop"]) {
        ShopViewController *controller = (ShopViewController *)segue.destinationViewController;
        [controller setUserid:self.userid];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
}

@end
