//
//  registerViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "registerViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"
#import <QuartzCore/QuartzCore.h>

@interface registerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *pcodeButton;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *captcha;
@property (strong, nonatomic) NSString *message;
@property WebViewJavascriptBridge* bridge;

@end

@implementation registerViewController

- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (void)prepareMyButton {
    [self.registerButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.registerButton.layer.cornerRadius = 10.0f;
}

- (void)refreshCaptcha {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"https://secure.boxbuy.cc/vcode?_rnd=%@", [self timeStamp]];
    [self.captchaButton setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:requestUrl]]] forState:UIControlStateNormal];
}

- (IBAction)captchaButtonTouchUpInside:(UIButton *)sender {
    [self refreshCaptcha];
}

/*- (BOOL)checkCaptcha {

}

- (IBAction)pcodeButtonTouchUpInside:(UIButton *)sender {
    if (![self checkCaptcha]) {
        [self popAlert:<#(NSString *)#> withMessage:<#(NSString *)#>];
    }
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self refreshCaptcha];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注册新账号"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"注册新账号"];
}

@end
