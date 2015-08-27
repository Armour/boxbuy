//
//  VerificationViewController.m
//  YunGeZi
//
//  Created by Armour on 5/20/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "VerificationViewController.h"
#import "MyNavigationController.h"
#import "MobClick.h"
#import "DeviceDetect.h"

@interface VerificationViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *uesrnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswdButton;
@property (weak, nonatomic) IBOutlet UIButton *startVerificationButton;
@property (weak, nonatomic) IBOutlet UILabel *alertInforLabel;
@property (weak, nonatomic) IBOutlet UILabel *upInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *downInfoLabel;
@property (nonatomic) NSUInteger preferredFontSize;
@property (nonatomic) BOOL isShowPasswd;

@end

@implementation VerificationViewController

#pragma mark - Prepare My Item

- (void)prepareMyButton {
    [self.startVerificationButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.startVerificationButton.layer.cornerRadius = 10.0f;
    self.isShowPasswd = NO;
}

- (void)prepareMyTextField {
    self.uesrnameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeNever;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
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
    self.uesrnameTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.passwordTextField.font = [UIFont boldSystemFontOfSize:self.preferredFontSize];
    self.upInfoLabel.font = [UIFont systemFontOfSize:self.preferredFontSize + 1];
    self.downInfoLabel.font = [UIFont systemFontOfSize:self.preferredFontSize - 3];
    self.startVerificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize + 3];
}

#pragma mark - Button Touch Event

- (IBAction)verificationButtonTouchUpInside:(UIButton *)sender {

}

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    NSLog(@"!!");
    self.isShowPasswd ^= 1;
    self.passwordTextField.secureTextEntry = !self.isShowPasswd;
    NSString* imageName = self.isShowPasswd ? @"eye_open" : @"eye_close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Gesture

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"身份认证"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyTextField];
    [self prepareMyIndicator];
    [self prepareMyFont];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"身份认证"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
