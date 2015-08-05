//
//  ViewController.m
//  YunGeZi
//
//  Created by Armour on 4/27/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "MyTabBarController.h"
#import "MobClick.h"

@interface ViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *refresh_token;
@property (strong, nonatomic) NSString *expire_time;

@end


@implementation ViewController

enum {
    textUsernameTag = 0,
    textPasswordTag = 1
};

@synthesize access_token = _access_token;

- (NSString *)access_token {
    if (!_access_token) {
        _access_token = [[NSString alloc] init];
    }
    return _access_token;
}

- (void)setAccess_token:(NSString *)access_token {
    _access_token = access_token;
}

- (void)prepareMyButton {
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.loginButton.layer.cornerRadius = 10.0f;
}

- (void)prepareMyTextField {
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    self.textUsername.tag = textUsernameTag;
    self.textPassword.tag = textPasswordTag;
    self.textUsername.layer.cornerRadius = 10.0f;
    self.textPassword.layer.cornerRadius = 10.0f;
    self.textUsername.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textPassword.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textUsername.layer.borderWidth = 1.0f;
    self.textPassword.layer.borderWidth = 1.0f;
    self.textUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyTextField];
    [self prepareMyIndicator];
}

- (IBAction)loginButtonTouchUpInside:(UIButton *)sender {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
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

            self.access_token = [[NSString alloc] initWithFormat:@"%@", jsonData[@"access_token"]];
            self.refresh_token = [[NSString alloc] initWithFormat:@"%@", jsonData[@"refresh_token"]];
            self.expire_time = [[NSString alloc] initWithFormat:@"%@", jsonData[@"expire_time"]];

            status = [jsonData[@"err"] integerValue];
        }
        @catch (NSException *exception) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showTabBarController"]){
        MyTabBarController *controller = (MyTabBarController *)segue.destinationViewController;
        [controller setAccess_token:self.access_token];
        [controller setRefresh_token:self.refresh_token];
        [controller setExpire_time:self.expire_time];
    }
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
    [MobClick beginLogPageView:@"登录界面"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"登录界面"];
}

@end
