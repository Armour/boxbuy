//
//  VerificationViewController.m
//  YunGeZi
//
//  Created by Armour on 5/20/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "VerificationViewController.h"
#import "MyNavigationController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MobClick.h"
#import "DeviceDetect.h"
#import "LoginInfo.h"

@interface VerificationViewController()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property (weak, nonatomic) IBOutlet UITextField *uesrnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswdButton;
@property (weak, nonatomic) IBOutlet UIButton *startVerificationButton;
@property (weak, nonatomic) IBOutlet UILabel *alertInforLabel;
@property (weak, nonatomic) IBOutlet UILabel *upInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *downInfoLabel;
@property (nonatomic) NSUInteger preferredFontSize;
@property (nonatomic) BOOL isShowPasswd;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation VerificationViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"身份认证"];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMyButton];
    [self prepareMyTextField];
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self prepareMyFont];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"身份认证"];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare My Item

- (void)prepareMyButton {
    [self.startVerificationButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.73 blue:0.56 alpha:1.00]];
    self.startVerificationButton.layer.cornerRadius = 10.0f;
    self.isShowPasswd = NO;
    self.alertInforLabel.layer.cornerRadius = 10.0f;;
    self.alertInforLabel.clipsToBounds = YES;
    [self.alertInforLabel setText:@"加载中..."];
    [self.alertInforLabel setHidden:YES];
}

- (void)prepareMyTextField {
    self.uesrnameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeNever;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setCenter:CGPointMake(self.alertInforLabel.center.x - 50, self.alertInforLabel.center.y)];
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
    self.alertInforLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 1];
    self.startVerificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize + 3];
}

#pragma mark - Prepare Loading Mask 

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

- (IBAction)verificationButtonTouchUpInside:(UIButton *)sender {
    [self.timer invalidate];
    [self.alertInforLabel setHidden:YES];
    [self.alertInforLabel setAlpha:1.0];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"] isEqualToString:@"0"]) {
        [self addLoadingMask];
        [self.activityIndicator startAnimating];
        [self.view bringSubviewToFront:self.alertInforLabel];
        [self.view bringSubviewToFront:self.activityIndicator];
        [self.alertInforLabel setText:@"加载中..."];
        [self.alertInforLabel setHidden:NO];
        [self startAuthentication];
    } else {
        [self popAlert:@"无法验证" withMessage:@"您好像没有选择学校😂"];
    }
}

- (IBAction)showPasswdButtonTouchUpInside:(UIButton *)sender {
    self.isShowPasswd ^= 1;
    self.passwordTextField.secureTextEntry = !self.isShowPasswd;
    NSString* imageName = self.isShowPasswd ? @"eye_open" : @"eye_close";
    [self.showPasswdButton setImage:[UIImage imageNamed:imageName]
                           forState:UIControlStateNormal];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - School Authentication

- (void)startAuthentication {
    self.manager = [AFHTTPRequestOperationManager manager];
    [self.manager POST:@"http://v2.api.boxbuy.cc/getSchoolAuthenticationApplyAbility"
            parameters:@{@"schoolid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"]}
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self setAccountSchool];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self removeLoadingMask];
                  [self.activityIndicator stopAnimating];
                  [self.alertInforLabel setText:@"请求验证信息失败..."];
                  [self setAlertDisappearTimer];
              }];
}

- (void)setAccountSchool {
    [self.manager POST:@"http://v2.api.boxbuy.cc/setAccountSchool"
            parameters:@{@"schoolid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"],
                         @"access_token" : [LoginInfo sharedInfo].accessToken }
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   [self addAuthenticationApply];
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self removeLoadingMask];
                  [self.activityIndicator stopAnimating];
                  [self.alertInforLabel setText:@"请求设置学校失败..."];
                  [self setAlertDisappearTimer];
               }];
}

- (void)addAuthenticationApply {
    NSDictionary *postData = @{@"username" : self.uesrnameTextField.text,
                               @"password" : self.passwordTextField.text,
                               @"authtype" : @"1",
                               @"access_token" : [LoginInfo sharedInfo].accessToken };
    [self.manager POST:@"https://secure.boxbuy.cc/addAuthenticationApply"
            parameters:postData
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   if ([[responseObject valueForKeyPath:@"uniError"] isEqual:@0]) {
                       [[LoginInfo sharedInfo] refreshSharedUserInfo];
                       [self popAlert:@"验证成功！" withMessage:@"返回首页中~\r\n 您可以上传商品啦!"];
                       [self performSegueWithIdentifier:@"verificationDone" sender:self];
                   } else {
                       [self removeLoadingMask];
                       [self.activityIndicator stopAnimating];
                       if ([[responseObject valueForKeyPath:@"uniError" ]isEqual:@1004])
                           self.alertInforLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 5];
                       else if ([[responseObject valueForKeyPath:@"uniError" ]isEqual:@2002])
                           self.alertInforLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 5];
                       else
                           self.alertInforLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 3];
                       [self.alertInforLabel setText:[responseObject valueForKeyPath:@"msg"]];
                       [self setAlertDisappearTimer];
                   }
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [self removeLoadingMask];
                   [self.activityIndicator stopAnimating];
                   [self.alertInforLabel setText:@"请求验证失败..."];
                   [self setAlertDisappearTimer];
               }];
}

#pragma mark - Alert Disapear Timer

- (void)setAlertDisappearTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.7f
                                                  target:self
                                                selector:@selector(disappearAlertButton)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)disappearAlertButton {
    [UILabel animateWithDuration:0.6 animations:^{
        self.alertInforLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.alertInforLabel setHidden:YES];
        self.alertInforLabel.alpha = 1.0;
        self.alertInforLabel.font = [UIFont boldSystemFontOfSize:self.preferredFontSize - 1];
    }];
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
