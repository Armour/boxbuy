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

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *AccountWebView;
@property WebViewJavascriptBridge* bridge;
@property (strong, nonatomic) NSString *userid;

@end

@implementation AccountViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_AccountWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        self.userid = data;
        if ([data isEqualToString:@"order"]) {
            [self performSegueWithIdentifier:@"showMyOrder" sender:self];
        } else if (![data isEqualToString:@"order"]){
            [self performSegueWithIdentifier:@"showMyShop" sender:self];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/account/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_AccountWebView loadRequest:request];
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

@end
