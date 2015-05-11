//
//  ObjectBuyResultInCategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 5/10/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectBuyResultInCategoryViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ObjectBuyResultInCategoryViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectBuyResultWebview;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectBuyResultInCategoryViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectBuyResultWebview handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"success"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        responseCallback(@"0.0");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/trades/confirmResult.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectBuyResultWebview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
