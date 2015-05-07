//
//  ViewController.m
//  YunGeZi
//
//  Created by Armour on 4/27/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ViewController.h"
#import "MyTabBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *refresh_token;
@property (strong, nonatomic) NSString *expire_time;

@end


@implementation ViewController

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

enum {
    textUsernameTag = 0,
    textPasswordTag
};

- (BOOL)shouldAutorotate {
    return false;
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

- (void)prepareMyButton {
    [self.loginButton setBackgroundColor:[UIColor purpleColor]];
    self.loginButton.layer.cornerRadius = 10.0f;
}

- (IBAction)loginButtonTouchUpInside:(UIButton *)sender {
    NSInteger status = -1;
    @try {
        NSURL *postURL = [NSURL URLWithString:@"https://secure.boxbuy.cc/oauth/authorize"];
        NSString *postStr = [NSString stringWithFormat:@"username=%@&password=%@&app_key=yourappkey&mobile=1&return_url=null", self.textUsername.text, self.textPassword.text];
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
        NSLog(@"Response code: %ld", (long)[requestResponse statusCode]);

        //NSString *responseData = [[NSString alloc] initWithData:requestHandler encoding:NSUTF8StringEncoding];

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
        NSLog(@"Exception: %@", exception);
    }

    /*NSLog(@"Cookie!: ");
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }*/

    if (status == 0) {
        [self performSegueWithIdentifier:@"showTabBarController" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyTextField];
    [self prepareMyButton];

    /*NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (id obj in cookieArray) {
        [cookieJar deleteCookie:obj];
    }

    NSLog(@"Initial cookie!: ");
    NSHTTPCookie *cookie;
    for (cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
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

@end
