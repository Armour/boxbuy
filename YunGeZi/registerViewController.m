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
    dispatch_queue_t requestQueue = dispatch_queue_create("webRequestInLogin", NULL);
    dispatch_async(requestQueue, ^{
        NSInteger status = -1;
        @try {
            NSURL *postURL = [NSURL URLWithString:@"https://secure.boxbuy.cc/oauth/authorize"];
            NSString *postStr = [NSString stringWithFormat:@"app_key=X6K1Hfzr12EERq3ea0SZJC0XAWk4ojOy&mobile=1&return_url=null"];
            NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            NSString *postContentType = @"application/x-www-form-urlencoded";

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:postURL];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:postContentType forHTTPHeaderField:@"Content-Type"];
            [request setHTTPShouldHandleCookies:YES];
            [request setHTTPBody:postData];

            NSError *requestError = [[NSError alloc] init];
            NSHTTPURLResponse *requestResponse;
            NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
            //NSLog(@"Response code: %ld", (long)[requestResponse statusCode]);

            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization
                                      JSONObjectWithData:requestHandler
                                      options:NSJSONReadingMutableContainers
                                      error:&jsonError];
            NSLog(@"Response with json ==> %@", jsonData);

            status = [jsonData[@"err"] integerValue];
        }
        @catch (NSException *exception) {
            //NSLog(@"Exception: %@", exception);
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:TRUE];
            [self popAlert:@"登录失败" withMessage:@"您好像网络不太好哦╮(╯_╰)╭"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:TRUE];
            if (status == 0) {
                [self performSegueWithIdentifier:@"showTabBarController" sender:self];
            } else if (status == 10004) {
                [self popAlert:@"登录失败" withMessage:@"您输入的密码有误╮(╯_╰)╭"];
            } else if (status == 10002) {
                [self popAlert:@"登录失败" withMessage:@"您输入的用户名并不存在╮(╯_╰)╭"];
            }
        });
    });
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
