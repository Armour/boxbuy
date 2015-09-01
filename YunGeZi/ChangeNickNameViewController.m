//
//  ChangeNickNameViewController.m
//  YunGeZi
//
//  Created by Armour on 5/20/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ChangeNickNameViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface ChangeNickNameViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@end


@implementation ChangeNickNameViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"修改昵称"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"修改昵称"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare Activity Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.4;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - Button Touch Event

- (IBAction)changeNicknameButtonTouchUpInside:(UIBarButtonItem *)sender {
    [self addLoadingMask];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/setAccountNickname"
       parameters:@{@"nickname" : self.nicknameTextField.text,
                    @"access_token" : [LoginInfo sharedInfo].accessToken}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if ([[responseObject valueForKeyPath:@"uniError"] isEqual:@0]) {
                  [[LoginInfo sharedInfo] refreshSharedUserInfo];
                  [self popAlert:@"修改成功~" withMessage:@"耶！改名成功啦~😝"];
                  [self.navigationController popViewControllerAnimated:YES];
              } else {
                  [self popAlert:@"修改失败" withMessage:[responseObject valueForKeyPath:@"msg"]];
              }
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"修改失败" withMessage:@"网络不好，请稍后重试~"];
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
          }];
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
