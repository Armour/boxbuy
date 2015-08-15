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
#import "DeviceDetect.h"

@interface RegisterViewController ()

@property (nonatomic) NSUInteger preferredFontSize;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *pcodeButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *pcodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswdButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorCaptcha;

@property (nonatomic) BOOL isShowPasswd;
@property (nonatomic) BOOL firstTimeRefreshCaptcha;

@end


@implementation RegisterViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注册新账号"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyIndicator];
    [self prepareMyNotification];
    [self prepareMyFont];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"注册新账号"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Check Regex

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

#pragma mark - Prepare My Item

- (void)prepareMyButton {
    [self.registerButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    [self.captchaButton setBackgroundColor:[UIColor colorWithRed:0.99 green:0.66 blue:0.15 alpha:1.00]];
    [self.pcodeButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.registerButton.layer.cornerRadius = 10.0f;
    self.captchaButton.layer.cornerRadius = 3.0f;
    self.pcodeButton.layer.cornerRadius = 3.0f;
    self.isShowPasswd = NO;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];

    self.firstTimeRefreshCaptcha = YES;
    self.activityIndicatorCaptcha = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorCaptcha setCenter:self.captchaButton.center];
    [self.activityIndicatorCaptcha setHidesWhenStopped:TRUE];
    [self.activityIndicatorCaptcha setHidden:YES];
    [self.view addSubview:self.activityIndicatorCaptcha];
    [self.view bringSubviewToFront:self.activityIndicatorCaptcha];
}

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPcodeButton:) name:@"CountDownTimerInRegister" object:nil];
}

- (void)prepareMyFont {
    if (IS_IPHONE_4_OR_LESS)
        self.preferredFontSize = 14;
    else if (IS_IPHONE_5)
        self.preferredFontSize = 15;
    else if (IS_IPAD)
        self.preferredFontSize = 18;
    else
        self.preferredFontSize = 17;
    self.phoneTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.passwordTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.captchaTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.pcodeTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.captchaButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 3];
    self.pcodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 3];
    self.registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize + 3];
}

#pragma mark - Captcha

- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (void)refreshCaptcha {
    [self.activityIndicatorCaptcha setHidden:NO];
    [self.activityIndicatorCaptcha startAnimating];
    dispatch_queue_t requestQueue = dispatch_queue_create("refreshCaptcha", NULL);
    dispatch_async(requestQueue, ^{
        NSString *requestUrl = [[NSString alloc] initWithFormat:@"https://secure.boxbuy.cc/vcode?_rnd=%@", [self timeStamp]];
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.captchaButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            if ([self firstTimeRefreshCaptcha]) {
                [self.captchaButton setTitle:@"" forState:UIControlStateNormal];
                [self setFirstTimeRefreshCaptcha:NO];
            }
            if (data == nil) {
                [self.captchaButton setTitle:@"点击刷新" forState:UIControlStateNormal];
                [self setFirstTimeRefreshCaptcha:YES];
            }
            [self.activityIndicatorCaptcha stopAnimating];
            [self.activityIndicatorCaptcha setHidden:TRUE];
        });
    });
}

- (IBAction)captchaButtonTouchUpInside:(UIButton *)sender {
    [self refreshCaptcha];
}

#pragma mark - Phone Code

- (void)refreshPcodeButton:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSInteger count = [[dict objectForKey:@"count"] intValue];
    if (count != 0) {
        self.pcodeButton.enabled = NO;
        [self.pcodeButton setTitle:[[NSString alloc] initWithFormat:@"等待%2ld秒", (long)count] forState:UIControlStateDisabled];
    } else {
        self.pcodeButton.enabled = YES;
    }
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
              //NSLog(@"JSON: %@", responseObject);
              NSError *jsonError = [[NSError alloc] init];
              NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
              if ([data[@"err"] integerValue] == 0) {
                  [self popAlert:@"" withMessage:[NSString stringWithFormat:@"短信已发送至%@，请注意查收", self.phoneTextField.text]];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPcodeInRegisterSuccessful" object:self userInfo:nil];
              } else {
                  [self popAlert:@"错误" withMessage:[NSString stringWithFormat:@"%@", data[@"msg"]]];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPcodeInRegisterSuccessful" object:self userInfo:nil];
              }
              [self.activityIndicator stopAnimating];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //NSLog(@"ERROR: %@", error);
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
}

#pragma mark - Register

- (void)tryRegister {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *postData = @{@"username" : self.phoneTextField.text,
                               @"password" : self.passwordTextField.text,
                               @"pcode"    : self.pcodeTextField.text};
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
                  [self performSegueWithIdentifier:@"chooseSchool" sender:self];
              } else {
                  [self popAlert:@"错误" withMessage:@"注册失败"];
                  [self performSegueWithIdentifier:@"chooseSchool" sender:self];    // delete this line when debug finished!
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
    /*if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误"];
    else if (![self checkPCode])
        [self popAlert:@"格式错误" withMessage:@"验证码格式错误"];
    else*/
        [self tryRegister];
}

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    self.isShowPasswd ^= 1;
    self.passwordTextField.secureTextEntry = !self.isShowPasswd;
    NSString* imageName = self.isShowPasswd ? @"eye_open" : @"eye_close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
