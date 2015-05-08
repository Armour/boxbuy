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
@property WebViewJavascriptBridge* bridge;

@end

@implementation registerViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_registerWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        if ([data isEqualToString:@"true"]) {
            //[self popAlert:@"注册成功" withMessage:@"注册成功!"];
            [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
        } else if ([data isEqualToString:@"false"]) {
            //[self popAlert:@"注册失败" withMessage:@"注册失败"];
            [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
        } else if ([data isEqualToString:@"back"]) {
            [self performSegueWithIdentifier:@"backToLoginFromRegister" sender:self];
        }
        responseCallback(@"0.0");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/register.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_registerWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
