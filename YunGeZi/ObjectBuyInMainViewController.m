//
//  ObjectBuyInMainViewController.m
//  YunGeZi
//
//  Created by Armour on 5/10/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectBuyInMainViewController.h"
#import "ObjectBuyResultInMainViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ObjectBuyInMainViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectBuyWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectBuyInMainViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectBuyWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self performSegueWithIdentifier:@"obejectBuyResultInMain" sender:self];
        }
        responseCallback(self.objectNumber);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/trades/confirm.html?item_id=%@", self.objectNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectBuyWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
