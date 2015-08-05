//
//  registerViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "registerViewController.h"
#import "MobClick.h"
#import "AFNetworking.h"

@interface registerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *pcodeButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *pcodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswdButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL isShowPasswd;

@end


@implementation registerViewController

@synthesize isShowPasswd;

- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
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

- (BOOL)checkPCode {
    return [self checkRegex:self.pcodeTextField.text withPattern:@"[0-9]{6}"];
}

- (void)prepareMyButton {
    [self.registerButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    [self.pcodeButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.registerButton.layer.cornerRadius = 10.0f;
    self.pcodeButton.layer.cornerRadius = 3.0f;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)refreshCaptcha {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"https://secure.boxbuy.cc/vcode?_rnd=%@", [self timeStamp]];
    [self.captchaButton setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:requestUrl]]] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyIndicator];
    [self refreshCaptcha];
    self.isShowPasswd = NO;
}

- (IBAction)captchaButtonTouchUpInside:(UIButton *)sender {
    [self refreshCaptcha];
}

- (void)getPcode {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postData = @{@"phone" : self.phoneTextField.text,
                               @"vcode" : self.captchaTextField.text};
    [manager POST:@"https://secure.boxbuy.cc/sendPhoneCode"
       parameters:postData
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSError *jsonError = [[NSError alloc] init];
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            if ([data[@"err"] integerValue] == 0) {
                [self popAlert:@"" withMessage:[NSString stringWithFormat:@"短信已发送至%@，请注意查收", self.phoneTextField.text]];
            } else {
                [self popAlert:@"错误" withMessage:[NSString stringWithFormat:@"%@", data[@"msg"]]];
            }
            [self.activityIndicator stopAnimating];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ERROR: %@", error);
            [self popAlert:@"错误" withMessage:@"短息发送失败，请稍候重试"];
            [self.activityIndicator stopAnimating];
        }];
}

- (IBAction)pcodeButtonTouchUpInside:(UIButton *)sender {
    if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误"];
    else if (![self checkCaptcha])
        [self popAlert:@"格式错误" withMessage:@"图片验证码格式错误"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误"];
    else
        [self getPcode];
    // post to https://secure.boxbuy.cc/sendPhoneCode
}

- (void)tryRegister {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postData = @{@"username" : self.phoneTextField.text,
                               @"password" : self.passwordTextField.text,
                               @"pcode" : self.pcodeTextField.text};
    [manager POST:@"https://secure.boxbuy.cc/register"
       parameters:postData
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              NSError *jsonError = [[NSError alloc] init];
              NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
              if ([data[@"err"] integerValue] == 0) {
                  [self popAlert:@"" withMessage:@"注册成功"];
              } else {
                  [self popAlert:@"错误" withMessage:@"注册失败"];
              }
              [self.activityIndicator stopAnimating];
              self.pcodeTextField.text = nil;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"ERROR: %@", error);
              [self popAlert:@"错误" withMessage:@"注册失败，请稍候重试"];
              [self.activityIndicator stopAnimating];
              [self refreshCaptcha];
          }];
}

- (IBAction)registerButtonTouchUpInside:(UIButton *)sender {
    if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误"];
    else if (![self checkPCode])
        [self popAlert:@"格式错误" withMessage:@"验证码格式错误"];
    else
        [self tryRegister];
}

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    self.isShowPasswd ^= 1;
    self.passwordTextField.secureTextEntry = !self.isShowPasswd;
    // TODO: image name
    NSString* imageName = self.isShowPasswd ? @"logo" : @"close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.passwordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注册新账号"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"注册新账号"];
}

@end
