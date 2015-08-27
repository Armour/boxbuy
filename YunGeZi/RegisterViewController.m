//
//  registerViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RegisterViewController.h"
#import "ChooseSchoolTableViewController.h"
#import "MobClick.h"
#import "AFNetworking.h"
#import "DeviceDetect.h"
#import "LoginInfo.h"

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
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) BOOL isShowPasswd;
@property (nonatomic) BOOL firstTimeRefreshCaptcha;
@property (nonatomic) CGFloat activityCenterXOffSet;
@property (nonatomic) CGFloat activityCenterYOffSet;

@end


@implementation RegisterViewController

@synthesize manager;

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
    [self prepareMyTextField];
    [self prepareMyNotification];
    [self prepareMyFont];
    [self prepareMyIndicator];
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

- (void)prepareMyTextField {
    self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeNever;
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
    [self.activityIndicatorCaptcha setCenter:CGPointMake(self.captchaButton.center.x + self.activityCenterXOffSet,
                                                         self.captchaButton.center.y + self.activityCenterYOffSet)];
    [self.activityIndicatorCaptcha setHidesWhenStopped:TRUE];
    [self.activityIndicatorCaptcha setHidden:YES];
    [self.view addSubview:self.activityIndicatorCaptcha];
    [self.view bringSubviewToFront:self.activityIndicatorCaptcha];
}

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPcodeButton:) name:@"CountDownTimerInRegister" object:nil];
    manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/png", @"application/json", nil];
}

- (void)prepareMyFont {
    if (IS_IPHONE_4_OR_LESS) {
        self.preferredFontSize = 14;
        self.activityCenterXOffSet = -45;
        self.activityCenterYOffSet = -25;
    } else if (IS_IPHONE_5) {
        self.preferredFontSize = 15;
        self.activityCenterXOffSet = -45;
        self.activityCenterYOffSet = -25;
    } else if (IS_IPAD) {
        self.preferredFontSize = 18;
        self.activityCenterXOffSet = 0;
        self.activityCenterYOffSet = 0;
    } else if (IS_IPHONE_6P) {
        self.preferredFontSize = 17;
        self.activityCenterXOffSet = 25;
        self.activityCenterYOffSet = 15;
    } else {
        self.preferredFontSize = 17;
        self.activityCenterXOffSet = 0;
        self.activityCenterYOffSet = 0;
    }
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
    NSString *time =  [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSRange lastDotRange = [time rangeOfString:@"." options:NSBackwardsSearch];
    if (lastDotRange.location != NSNotFound)
        return [time substringToIndex:lastDotRange.location];
    else
        return time;
}

- (void)refreshCaptcha {
    [self.activityIndicatorCaptcha startAnimating];
    [manager GET:@"https://secure.boxbuy.cc/vcode"
      parameters:@{@"_rnd" : [self timeStamp]}
         success:^(AFHTTPRequestOperation *operation, id responseData) {
             [self.captchaButton setBackgroundImage:[UIImage imageWithData:responseData] forState:UIControlStateNormal];
             if ([self firstTimeRefreshCaptcha]) {
                 [self.captchaButton setTitle:@"" forState:UIControlStateNormal];
                 [self setFirstTimeRefreshCaptcha:NO];
             }
             [self.activityIndicatorCaptcha stopAnimating];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self.captchaButton setTitle:@"点击刷新" forState:UIControlStateNormal];
             [self setFirstTimeRefreshCaptcha:YES];
             [self.activityIndicatorCaptcha stopAnimating];
         }];
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
        [self.pcodeButton setTitle:[[NSString alloc] initWithFormat:@"等待%ld秒", (long)count] forState:UIControlStateDisabled];
    } else {
        self.pcodeButton.enabled = YES;
    }
}

- (void)getPcode {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    NSDictionary *postData = @{@"phone" : self.phoneTextField.text,
                               @"vcode" : self.captchaTextField.text};
    [manager POST:@"https://secure.boxbuy.cc/sendPhoneCode"
       parameters:postData
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *jsonError = [[NSError alloc] init];
              NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
              if ([data[@"err"] integerValue] == 0) {
                  [self popAlert:@"" withMessage:[NSString stringWithFormat:@"短信已发送至%@，请注意查收", self.phoneTextField.text]];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPcodeInRegisterSuccessful" object:self userInfo:nil];
              } else {
                  [self popAlert:@"错误" withMessage:data[@"msg"]];
              }
              [self.activityIndicator stopAnimating];
              [self refreshCaptcha];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"ERROR: %@", error);
              [self popAlert:@"错误" withMessage:@"短息发送失败，请稍候重试"];
              [self.activityIndicator stopAnimating];
              [self refreshCaptcha];
          }];
}

- (IBAction)pcodeButtonTouchUpInside:(UIButton *)sender {
    if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误😣"];
    else if (![self checkCaptcha])
        [self popAlert:@"格式错误" withMessage:@"图片验证码格式错误😣"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误😣"];
    else
        [self getPcode];
}

#pragma mark - Register

- (void)tryRegister {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    NSDictionary *postData = @{@"username" : self.phoneTextField.text,
                               @"password" : self.passwordTextField.text,
                               @"pcode"    : self.pcodeTextField.text};
    [manager POST:@"https://secure.boxbuy.cc/register"
       parameters:postData
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *jsonError = [[NSError alloc] init];
              NSDictionary *data = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
              if ([data[@"err"] integerValue] == 0) {
                  [self popAlert:@"" withMessage:@"注册成功~😝"];
                  [self updateSharedToken];
                  [self performSegueWithIdentifier:@"chooseSchool" sender:self];
              } else {
                  [self popAlert:@"错误" withMessage:data[@"msg"]];
                  [self refreshCaptcha];
              }
              [self.activityIndicator stopAnimating];
              self.pcodeTextField.text = nil;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"错误" withMessage:@"收到了异次元波动的影响\r\n请稍候重试😱"];
              [self.activityIndicator stopAnimating];
              [self refreshCaptcha];
          }];
}

- (IBAction)registerButtonTouchUpInside:(UIButton *)sender {
    [self updateSharedToken];
    [self performSegueWithIdentifier:@"chooseSchool" sender:self];
    /*
    if (![self checkPhoneNumber])
        [self popAlert:@"格式错误" withMessage:@"手机号格式错误😣"];
    else if (![self checkPassword])
        [self popAlert:@"格式错误" withMessage:@"密码格式错误😣"];
    else if (![self checkPCode])
        [self popAlert:@"格式错误" withMessage:@"验证码格式错误😣"];
    else
        [self tryRegister];*/
}

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    self.isShowPasswd ^= 1;
    self.passwordTextField.secureTextEntry = !self.isShowPasswd;
    NSString* imageName = self.isShowPasswd ? @"eye_open" : @"eye_close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Update Login Shared Token

- (void)updateSharedToken {
    NSDictionary *postData = @{@"username" : @"18868101893",//self.phoneTextField.text,
                               @"password" : @"222222",//self.passwordTextField.text,
                               @"app_key"  : @"X6K1Hfzr12EERq3ea0SZJC0XAWk4ojOy",
                               @"mobile"   : @"1",
                               @"return_url" : @"null"};
    [manager POST:@"https://secure.boxbuy.cc/oauth/authorize"
       parameters:postData
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *jsonError = nil;
              NSDictionary *jsonData = [NSJSONSerialization
                                        JSONObjectWithData:responseObject
                                        options:NSJSONReadingMutableContainers
                                        error:&jsonError];
              [[LoginInfo sharedInfo] updateWithAccessToken:[[NSString alloc] initWithFormat:@"%@", jsonData[@"access_token"]]
                                               refreshToken:[[NSString alloc] initWithFormat:@"%@", jsonData[@"refresh_token"]]
                                                 expireTime:[[NSString alloc] initWithFormat:@"%@", jsonData[@"expire_time"]]];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"网络不好" withMessage:@"点击后将自动重试, 如持续出现此窗口就说明你网断啦。。"];
              [self updateSharedToken];
          }];
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chooseSchool"]) {
        ChooseSchoolTableViewController *controller = (ChooseSchoolTableViewController *)segue.destinationViewController;
        [controller setTitle:@"设置查看学校"];
    }
}

#pragma mark - Gesture

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
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
