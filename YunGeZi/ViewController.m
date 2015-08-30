//
//  ViewController.m
//  YunGeZi
//
//  Created by Armour on 4/27/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "RootViewController.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface ViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSString *expireTime;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIView *loadingMask;
@property (nonatomic) NSInteger timerCountInRegister;
@property (nonatomic) NSInteger timerCountInChangePassword;
@property (nonatomic) BOOL isShowPasswd;
@property (weak, nonatomic) IBOutlet UIButton *showPasswdButton;

@end


@implementation ViewController

enum {
    textUsernameTag = 0,
    textPasswordTag = 1
};

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyTextField];
    [self prepareMyIndicator];
    [self prepareMyNotification];
    [self prepareLoadingMask];
    [self prepareUserDefault];
    self.textUsername.text = @"18868101893";
    self.textPassword.text = @"222222";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"登录界面"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"登录界面"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare My Item

- (void)prepareMyButton {
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.loginButton.layer.cornerRadius = 10.0f;
    [self.registerButton setBackgroundColor:[UIColor whiteColor]];
    self.registerButton.layer.cornerRadius = 10.0f;
    self.registerButton.layer.borderWidth = 1.0f;
    self.registerButton.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)prepareMyTextField {
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    self.textUsername.tag = textUsernameTag;
    self.textPassword.tag = textPasswordTag;
    self.textUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.isShowPasswd = NO;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startCountDownInRegister)
                                                 name:@"GetPcodeInRegisterSuccessful"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startCountDownInChangePassword)
                                                 name:@"GetPcodeInChangePasswordSuccessful"
                                               object:nil];
}

#pragma mark - Count Down

- (void)onCountDownInRegister {
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.timerCountInRegister] forKey:@"count"];
    if (self.timerCountInRegister != 0) {
        self.timerCountInRegister--;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountDownTimerInRegister" object:self userInfo:dict];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountDownTimerInRegister" object:self userInfo:dict];
        [self.timer invalidate];
    }
}

- (void)onCountDownInChangePassword {
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.timerCountInChangePassword] forKey:@"count"];
    if (self.timerCountInChangePassword != 0) {
        self.timerCountInChangePassword--;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountDownTimerInChangePassword" object:self userInfo:dict];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountDownTimerInChangePassword" object:self userInfo:dict];
        [self.timer invalidate];
    }
}

- (void)startCountDownInRegister {
    self.timerCountInRegister = 120;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(onCountDownInRegister)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)startCountDownInChangePassword {
    self.timerCountInChangePassword = 120;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(onCountDownInChangePassword)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.6;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - LoginButton Clicked

- (IBAction)loginButtonTouchUpInside:(UIButton *)sender {
    [self.view endEditing:YES];
    [self.activityIndicator startAnimating];
    [self addLoadingMask];
    [self.view bringSubviewToFront:self.activityIndicator];
    dispatch_queue_t requestQueue = dispatch_queue_create("webRequestInLogin", NULL);
    dispatch_async(requestQueue, ^{
        NSInteger status = -1;
        @try {
            NSURL *postURL = [NSURL URLWithString:@"https://secure.boxbuy.cc/oauth/authorize"];
            NSString *postStr = [NSString stringWithFormat:@"username=%@&password=%@&app_key=X6K1Hfzr12EERq3ea0SZJC0XAWk4ojOy&mobile=1&return_url=null", self.textUsername.text, self.textPassword.text];
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

            NSError *jsonError = nil;
            NSDictionary *jsonData = [NSJSONSerialization
                                      JSONObjectWithData:requestHandler
                                      options:NSJSONReadingMutableContainers
                                      error:&jsonError];
            NSLog(@"Response with json ==> %@", jsonData);

            self.accessToken = [[NSString alloc] initWithFormat:@"%@", jsonData[@"access_token"]];
            self.refreshToken = [[NSString alloc] initWithFormat:@"%@", jsonData[@"refresh_token"]];
            self.expireTime = [[NSString alloc] initWithFormat:@"%@", jsonData[@"expire_time"]];

            [[LoginInfo sharedInfo] updateWithAccessToken:self.accessToken
                                             refreshToken:self.refreshToken
                                               expireTime:self.expireTime];
            
            status = [jsonData[@"err"] integerValue];
        }
        @catch (NSException *exception) {
            [self.activityIndicator stopAnimating];
            [self popAlert:@"登录失败" withMessage:@"您好像网络不太好哦😥"];
            [self removeLoadingMask];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if (status == 0) {
                [self performSegueWithIdentifier:@"goToMainPage" sender:self];
            } else if (status == 10004) {
                [self popAlert:@"登录失败" withMessage:@"您输入的密码有误😣"];
            } else if (status == 10002) {
                [self popAlert:@"登录失败" withMessage:@"您输入的用户名并不存在😨"];
            }
            [self removeLoadingMask];
        });
    });
}

#pragma mark - User Defaults

- (void)prepareUserDefault {
    if ([self getLocalSchoolId] == nil) {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"schoolId", @"未设置学校", @"schoolName", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)getLocalSchoolId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"];
}

- (NSString *)getLocalSchoolName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolName"];
}

#pragma mark - Show Password Button

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    self.isShowPasswd ^= 1;
    self.textPassword.secureTextEntry = !self.isShowPasswd;
    NSString* imageName = self.isShowPasswd ? @"eye_open" : @"eye_close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.textPassword becomeFirstResponder];
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    switch (textField.tag) {
        case textUsernameTag:
            self.textUsername.layer.borderColor = [[UIColor colorWithRed:0 green:204 blue:100 alpha:1] CGColor];
            break;
        case textPasswordTag:
            self.textPassword.layer.borderColor = [[UIColor colorWithRed:0 green:204 blue:100 alpha:1] CGColor];
            break;
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:@"TextFieldKeyboardAppear" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState: YES];
    switch (textField.tag) {
        case textUsernameTag:
            //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 100, self.view.frame.size.width, self.view.frame.size.height);
            break;
        case textPasswordTag:
            //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 150, self.view.frame.size.width, self.view.frame.size.height);
            break;
        default:
            break;
    }
    [UIView commitAnimations];
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case textUsernameTag:
            self.textUsername.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            break;
        case textPasswordTag:
            self.textPassword.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            break;
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:@"TextFieldKeyboardDisappear" context:nil];
    [UIView setAnimationDuration:0.15];
    [UIView setAnimationBeginsFromCurrentState: YES];
    switch (textField.tag) {
        case textUsernameTag:
            //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height);
            break;
        case textPasswordTag:
            //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 150, self.view.frame.size.width, self.view.frame.size.height);
            break;
        default:
            break;
    }
    [textField resignFirstResponder];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Gesture

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)forgetPasswordIconTouchUpInside:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"forgetPassword" sender:self];
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
