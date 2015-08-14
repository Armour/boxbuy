//
//  AccountViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AccountViewController.h"
#import "MyTabBarController.h"
#import "WebViewJavascriptBridge.h"
#import "ShopViewController.h"
#import "MyNavigationController.h"
#import "MobClick.h"

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
    UIImage *userPhoto = [UIImage imageNamed:@"DefaultUserImage"];
    [self.headerBackgroundImage setImage:userPhoto];
    [self.userImage setImage:userPhoto];
    self.userImage.layer.cornerRadius = self.userImage.bounds.size.height / 2;
    self.userImage.clipsToBounds = YES;
    self.userNameLabel.text = @"用户名balabalalalal";
    self.userMarkImage.image = [UIImage imageNamed:@"close"];
    {
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
    [self setUserResume:@"Hello World!"];
    
    {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.headerBackgroundImage.bounds;
        [self.headerBackgroundImage addSubview:effectView];
    }
    
}

- (void)prepareNavigation {
    [self initUserInfo];
    
    self.navigationController.navigationBarHidden = YES;

    {
        CGRect _frame = self.headerView.frame;
        _frame.size.height = self.view.bounds.size.height - 44 * 5 - 50;
        self.headerView.frame = _frame;
    }
    self.goodsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setGoodsCount:0];
    self.focusButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setFocusCount:0];
    self.fansButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setFansCount:0];
    [self setCommentsCount:0];
}

#pragma mark - Button Action

- (IBAction)backButtonTouchUpInside:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToMyInfoButtonTouchUpInside:(id)sender {
    NSLog(@"MyInfo");
}

- (IBAction)goodsButtonTouchUpInside:(id)sender {
    NSLog(@"GOODS");
}

- (IBAction)focusButtonTouchUpInside:(id)sender {
    NSLog(@"FOUCUS");
}

- (IBAction)fansButtonTouchUpInside:(id)sender {
    NSLog(@"FANS");
}

- (IBAction)commentsButtonTouchUpInside:(id)sender {
    NSLog(@"COMMENT");
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.item) {
        case 0: // 我的店铺
            NSLog(@"我的店铺");
            break;
        case 1: // 全部订单
            NSLog(@"全部订单");
            break;
        case 2: // 我的回收
            NSLog(@"我的回收");
            break;
        case 3: // 我的钱包
            NSLog(@"我的钱包");
            break;
        case 4: // 我的收藏
            NSLog(@"我的收藏");
            break;
        default:
            break;
    }
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

#pragma mark - Inner Helper

- (void)setGoodsCount:(NSInteger)count {
    [self.goodsButton setTitle:[NSString stringWithFormat:@"%ld\r\n商品", count]
                      forState:UIControlStateNormal];
}

- (void)setFocusCount:(NSInteger)count {
    [self.focusButton setTitle:[NSString stringWithFormat:@"%ld\r\n关注", count]
                      forState:UIControlStateNormal];
}

- (void)setFansCount:(NSInteger)count {
    [self.fansButton setTitle:[NSString stringWithFormat:@"%ld\r\n粉丝", count]
                     forState:UIControlStateNormal];
}

- (void)setCommentsCount:(NSInteger)count {
    [self.commentsButton setTitle:[NSString stringWithFormat:@"  已收到%ld条评价", count]
                         forState:UIControlStateNormal];
}

- (void)setUserResume:(NSString *)resume {
    self.userResumeLabel.text = resume;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self prepareNavigation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self prepareNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
}

@end
