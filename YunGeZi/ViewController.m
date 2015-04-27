//
//  ViewController.m
//  YunGeZi
//
//  Created by Armour on 4/27/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

enum {
    textUsernameTag = 0,
    textPasswordTag
};

- (void)prepareMyTextField {
    self.textUsername.delegate = self;
    self.textPassword.delegate = self;
    self.textUsername.tag = textUsernameTag;
    self.textPassword.tag = textPasswordTag;
    self.textUsername.layer.cornerRadius = 10.0f;
    self.textPassword.layer.cornerRadius = 10.0f;
    //self.textUsername.layer.masksToBounds = YES;
    //self.textPassword.layer.masksToBounds = YES;
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
        NSURL *postURL = [NSURL URLWithString:@"https://secure.boxbuy.cc/login"];
        NSString *postStr = [NSString stringWithFormat:@"username=%@&password=%@", self.textUsername.text, self.textPassword.text];
        NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSString *postContentType = @"application/x-www-form-urlencoded";

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:postURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:postContentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];

        NSError *requestError = [[NSError alloc] init];
        NSHTTPURLResponse *requestResponse;
        NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
        NSLog(@"Response code: %ld", (long)[requestResponse statusCode]);

        NSString *responseData = [[NSString alloc] initWithData:requestHandler encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);

        NSError *jsonError = nil;
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:requestHandler
                                  options:NSJSONReadingMutableContainers
                                  error:&jsonError];
        NSLog(@"Response with json ==> %@", jsonData);

        status = [jsonData[@"err"] integerValue];
        NSLog(@"Success: %ld",(long)status);

    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    if (status == 0) {
        [self performSegueWithIdentifier:@"showTabBarController" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyTextField];
    [self prepareMyButton];

    /*
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }
    */

    // Do any additional setup after loading the view, typically from a nib.
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

@end
