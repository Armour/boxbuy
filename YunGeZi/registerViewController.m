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
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *pcodeTextField;
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

- (BOOL)checkRegex:(NSString *)string withPattern:(NSString *)pattern {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    return match != nil;
}

- (BOOL)checkPhoneNumber {
    return [self checkRegex:self.phoneTextField.text withPattern:@"[0-9]{11}"];
}

- (BOOL)checkPassword {
    return [self checkRegex:self.passwordTextField.text withPattern:@"[\\S]{6,16}"];
}

- (BOOL)checkCaptcha {
    return [self checkRegex:self.captchaTextField.text withPattern:@"[a-zA-Z0-9]{4}"];
}

- (void)refreshCaptcha {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"https://secure.boxbuy.cc/vcode?_rnd=%@", [self timeStamp]];
    [self.captchaButton setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:requestUrl]]] forState:UIControlStateNormal];
}

- (IBAction)captchaButtonTouchUpInside:(UIButton *)sender {
    [self refreshCaptcha];
}

- (IBAction)pcodeButtonTouchUpInside:(UIButton *)sender {
    if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误"];
    else if (![self checkCaptcha])
        [self popAlert:@"格式错误" withMessage:@"图片验证码格式错误"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误"];
}

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
