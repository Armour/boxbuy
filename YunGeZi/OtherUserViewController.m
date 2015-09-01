//
//  OtherUserViewController.m
//  YunGeZi
//
//  Created by Armour on 8/31/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OtherUserViewController.h"
#import "OtherAvatarViewController.h"
#import "UIImageView+WebCache.h"
#import "LoginInfo.h"
#import "MobClick.h"
#import "DeviceDetect.h"

@interface OtherUserViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userResumeLabel;
@property (weak, nonatomic) IBOutlet UIButton *productsButton;
@property (weak, nonatomic) IBOutlet UIButton *fansButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) NSString *headiconid;
@property (strong, nonatomic) NSString *hashid;

@end

@implementation OtherUserViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInfo];
    [self prepareButton];
    [self prepareBlurEffect];
    [self getUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"他人信息"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    [[LoginInfo sharedInfo] updateToken];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"他人信息"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibg"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inner Helper

- (void)setProductsCount:(NSInteger)count {
    [self.productsButton setTitle:[NSString stringWithFormat:@"成交量 %ld", (long)count]
                         forState:UIControlStateNormal];
}

- (void)setFansCount:(NSInteger)count {
    [self.fansButton setTitle:[NSString stringWithFormat:@"粉丝数 %ld", (long)count]
                       forState:UIControlStateNormal];
}

- (void)setFollowButtonRadius {
    self.followButton.layer.cornerRadius = 6.0f;
    self.followButton.layer.borderWidth = 1.0f;
    self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.followButton.clipsToBounds = YES;
}

- (void)setCommentsCount:(NSInteger)count {
    [self.commentsButton setTitle:[NSString stringWithFormat:@"    已收到%ld条评价", (long)count]
                         forState:UIControlStateNormal];
}

- (void)setUserResume:(NSString *)resume {
    self.userResumeLabel.text = resume;
}

#pragma mark - Init User Info

- (void)initUserInfo {
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.height / 2;
    self.userImage.clipsToBounds = YES;
    self.userImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTouchUpInside)];
    [self.userImage addGestureRecognizer:tapGesture];
    if (IS_IPHONE_4_OR_LESS) {
        [self.userResumeLabel setHidden:YES];
    }
    [self setFollowButtonRadius];
    [self.headerBackgroundImage setImage:[UIImage imageNamed:@"default_headicon"]];
    [self.userImage setImage:[UIImage imageNamed:@"default_headicon"]];
    [self.view layoutIfNeeded];
}

#pragma mark - Refresh User Info

- (void)refreshUserInfo:(id)response {
    void (^_setImage)(UIImageView *) = ^(UIImageView *imageView) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-md.jpg", self.headiconid, self.hashid]]
                     placeholderImage:[UIImage imageNamed:@"default_headicon"]];
    };
    _setImage(self.headerBackgroundImage);
    _setImage(self.userImage);
    [self setProductsCount:[[response valueForKeyPath:@"Account.value_item"] integerValue]];
    [self setFansCount:[[response valueForKeyPath:@"Account.value_fan"] integerValue]];
    [self setUserResume:[response valueForKeyPath:@"Account.intro"]];
    [self setCommentsCount:[[response valueForKeyPath:@"Account.value_msg_recv"] integerValue]];
    [self.userNameLabel setText:[response valueForKeyPath:@"Account.nickname"]];
    if ([[response valueForKeyPath:@"Account.authstate"] integerValue] != 0) {
        [self.followButton setTitle:@"已认证" forState:UIControlStateNormal];
    } else {
        [self.followButton setTitle:@"未认证" forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"alertbg"] forState:UIControlStateNormal];
    }
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.00]];
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - Prepare Blur Effect

- (void)prepareBlurEffect {
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.view layoutIfNeeded];
    effectView.frame = self.headerBackgroundImage.bounds;
    [self.headerBackgroundImage addSubview:effectView];
}

#pragma mark - Prepare Button

- (void)prepareButton {
    self.productsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.followButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.fansButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIView *innerBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.productsButton.frame.size.height * 0.2, 2, self.productsButton.frame.size.height * 0.7)];
    innerBorder.backgroundColor = [UIColor whiteColor];
    [self.fansButton addSubview:innerBorder];
    [self.commentsButton setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.3]];
}

#pragma mark - Get User Info 

- (void)getUserInfo {
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self addLoadingMask];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://v2.api.boxbuy.cc/getUserData"
       parameters:@{@"userid" : self.userid,
                    @"access_token" : [LoginInfo sharedInfo].accessToken}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.headiconid = [responseObject valueForKeyPath:@"Account.headiconid"];
              self.hashid = [responseObject valueForKeyPath:@"HeadIcon.hash"];
              [self refreshUserInfo:responseObject];
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"获取失败" withMessage:@"网络不太好，请稍后重试"];
              [self.navigationController popViewControllerAnimated:YES];
              [self.activityIndicator stopAnimating];
              [self removeLoadingMask];
          }];
}

#pragma mark - Gesture Event

- (void)userImageTouchUpInside {
    [self performSegueWithIdentifier:@"showOtherUserAvatar" sender:self];
}

- (IBAction)followButtonTouchUpInside:(UIButton *)sender {
    //[self popAlert:@"此功能后续版本开放" withMessage:@"敬请期待~"];
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OtherAvatarViewController *controller = segue.destinationViewController;
    [controller setHeadiconid:self.headiconid];
    [controller setHashid:self.hashid];
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
