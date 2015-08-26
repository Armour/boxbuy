//
//  AccountViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AccountViewController.h"
#import "MyTabBarController.h"
#import "LoginInfo.h"
#import "WebViewJavascriptBridge.h"
#import "ShopViewController.h"
#import "MyNavigationController.h"
#import "MobClick.h"
#import "UIImageView+WebCache.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userResumeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userMarkImage;
@property (weak, nonatomic) IBOutlet UIView *userNameAndMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameAndMarkViewLengthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *goodsButton;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UIButton *fansButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;

@end


@implementation AccountViewController

#pragma mark - Preparation

- (void)initUserInfo {
    {
        void (^_setImage)(UIImageView *) = ^(UIImageView *imageView) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:[LoginInfo sharedInfo].photoUrlString]
                         placeholderImage:[UIImage imageNamed:@"default_headicon"]];
        };
        _setImage(self.headerBackgroundImage);
        _setImage(self.userImage);
    }
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.height / 2;
    self.userImage.clipsToBounds = YES;
    self.userNameLabel.text = [LoginInfo sharedInfo].nickname;
    self.userMarkImage.image = [UIImage imageNamed:@"close"];
    [self setUserResume:[LoginInfo sharedInfo].intro];
    
    {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.headerBackgroundImage.bounds;
        [self.headerBackgroundImage addSubview:effectView];
    }
    
}

- (void)prepareNavigation {
    [self initUserInfo];
    {
        CGRect _frame = self.headerView.frame;
        _frame.size.height = self.view.bounds.size.height - 44 * 5 - 50;
        self.headerView.frame = _frame;
    }
    self.goodsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setGoodsCount:[LoginInfo sharedInfo].numOfItem];
    self.focusButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setFocusCount:[LoginInfo sharedInfo].numOfFollow];
    self.fansButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setFansCount:[LoginInfo sharedInfo].numOfFan];
    
    [self setCommentsCount:0];
}

- (void)resizeUserNameAndMarkView {
    CGSize _labelSize = [self.userNameLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    CGRect _labelFrame = self.userNameLabel.frame;
    _labelFrame.size.width = _labelSize.width;
    self.userNameLabel.frame = _labelFrame;
    CGFloat _viewLength = _labelSize.width;
    if (YES) {  // HAS USER ID IMAGE
        _viewLength += 8 + self.userMarkImage.frame.size.width;
    }
    self.userNameAndMarkViewLengthConstraint.constant = _viewLength;
    CGRect _viewFrame = self.userNameAndMarkView.frame;
    _viewFrame.size.width = _viewLength;
    self.userNameAndMarkView.frame = _viewFrame;
}

- (void)prepareTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Button Action

- (IBAction)backButtonTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Delegate

#pragma mark - Inner Helper

- (void)setGoodsCount:(NSInteger)count {
    [self.goodsButton setTitle:[NSString stringWithFormat:@"%ld\r\n商品", (long)count]
                      forState:UIControlStateNormal];
}

- (void)setFocusCount:(NSInteger)count {
    [self.focusButton setTitle:[NSString stringWithFormat:@"%ld\r\n关注", (long)count]
                      forState:UIControlStateNormal];
}

- (void)setFansCount:(NSInteger)count {
    [self.fansButton setTitle:[NSString stringWithFormat:@"%ld\r\n粉丝", (long)count]
                     forState:UIControlStateNormal];
}

- (void)setCommentsCount:(NSInteger)count {
    [self.commentsButton setTitle:[NSString stringWithFormat:@"  已收到%ld条评价", (long)count]
                         forState:UIControlStateNormal];
}

- (void)setUserResume:(NSString *)resume {
    self.userResumeLabel.text = resume;
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareNavigation];
    [self prepareTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resizeUserNameAndMarkView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的"];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
    
    self.navigationController.navigationBarHidden = NO;
}

@end
