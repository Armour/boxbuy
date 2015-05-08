//
//  forgetPasswordViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "forgetPasswordViewController.h"
#import "WebViewJavascriptBridge.h"

@interface forgetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *forgetPasswordWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation forgetPasswordViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_forgetPasswordWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        if ([data isEqualToString:@"true"]) {
            [self popAlert:@"修改密码成功" withMessage:@"修改密码成功!"];
            [self performSegueWithIdentifier:@"backToLoginFromChangePassword" sender:self];
        } else if ([data isEqualToString:@"false"]) {
            [self popAlert:@"修改密码失败" withMessage:@"修改密码失败"];
            [self performSegueWithIdentifier:@"backToLoginFromChangePassword" sender:self];
        } else if ([data isEqualToString:@"back"]) {
            [self performSegueWithIdentifier:@"backToLoginFromChangePassword" sender:self];
        }
        responseCallback(@"0.0");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/forget.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_forgetPasswordWebView loadRequest:request];
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
    //[alert addButtonWithTitle:@"GOO"];
    [alert show];
}

@end
