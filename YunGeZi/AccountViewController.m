//
//  AccountViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountTableViewCell.h"
#import "LoginInfo.h"
#import "ShopViewController.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userResumeLabel;
@property (weak, nonatomic) IBOutlet UIButton *productsButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *fansButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *category;

@end


@implementation AccountViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInfo];
    [self prepareButton];
    [self prepareTableView];
    [self prepareMyNotification];
    [self prepareBlurEffect];
    [self refreshUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibg"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inner Helper

- (void)setProductsCount:(NSInteger)count {
    [self.productsButton setTitle:[NSString stringWithFormat:@"%ld\r\n商品", (long)count]
                         forState:UIControlStateNormal];
}

- (void)setFollowCount:(NSInteger)count {
    [self.followButton setTitle:[NSString stringWithFormat:@"%ld\r\n关注", (long)count]
                       forState:UIControlStateNormal];
}

- (void)setFansCount:(NSInteger)count {
    [self.fansButton setTitle:[NSString stringWithFormat:@"%ld\r\n粉丝", (long)count]
                     forState:UIControlStateNormal];
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
}

#pragma mark - Refresh User Info

- (void)refreshUserInfo {
    void (^_setImage)(UIImageView *) = ^(UIImageView *imageView) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:[LoginInfo sharedInfo].photoUrlString]
                     placeholderImage:[UIImage imageNamed:@"default_headicon"]];
    };
    _setImage(self.headerBackgroundImage);
    _setImage(self.userImage);
    [self setProductsCount:[LoginInfo sharedInfo].numOfItem];
    [self setFollowCount:[LoginInfo sharedInfo].numOfFollow];
    [self setFansCount:[LoginInfo sharedInfo].numOfFan];
    [self setCommentsCount:0];
    [self setUserResume:[LoginInfo sharedInfo].intro];
    [self.userNameLabel setText:[LoginInfo sharedInfo].nickname];
}

#pragma mark - Notification

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUserInfo)
                                                 name:@"CachedInfoRefreshed"
                                               object:nil];
}

#pragma mark - Prepare Blur Effect

- (void)prepareBlurEffect {
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.headerBackgroundImage.bounds;
    [self.headerBackgroundImage addSubview:effectView];
}

#pragma mark - Prepare Function

- (void)prepareButton {
    self.productsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.followButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.fansButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIView *topBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.productsButton.frame.size.width, 1)];
    UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.productsButton.frame.size.width, 1)];
    UIView *topBorder3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.productsButton.frame.size.width, 1)];
    topBorder1.backgroundColor = [UIColor whiteColor];
    topBorder2.backgroundColor = [UIColor whiteColor];
    topBorder3.backgroundColor = [UIColor whiteColor];
    [self.productsButton addSubview:topBorder1];
    [self.followButton addSubview:topBorder2];
    [self.fansButton addSubview:topBorder3];

    UIView *innerBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.productsButton.frame.size.height * 0.1, 1, self.productsButton.frame.size.height * 0.9)];
    UIView *innerBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.productsButton.frame.size.height * 0.1, 1, self.productsButton.frame.size.height * 0.9)];
    innerBorder1.backgroundColor = [UIColor whiteColor];
    innerBorder2.backgroundColor = [UIColor whiteColor];
    [self.followButton addSubview:innerBorder1];
    [self.fansButton addSubview:innerBorder2];

    [self.commentsButton setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.3]];
}

- (void)prepareTableView {
    self.category = [[NSMutableArray alloc] init];
    [self.category addObject:@"我的收藏"];
    [self.category addObject:@"全部订单"];
    [self.category addObject:@"我的店铺"];
    [self.category addObject:@"我的回收"];
    [self.category addObject:@"我的钱包"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = 10;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - Gesture Event

- (void)userImageTouchUpInside {
    [self performSegueWithIdentifier:@"showUserAvatar" sender:self];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.category count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
    [cell.tableViewCellTitle setText:[self.category objectAtIndex:indexPath.item]];
    [cell.tableViewInfoLabel setText:@""];
    [cell.tableViewSegueImageView setImage:[UIImage imageNamed:@"arrow-forward"]];
    [cell.tableViewNotiIficationImageView setImage:[UIImage new]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    } else if (indexPath.item == 1) {
        [self performSegueWithIdentifier:@"showMyOrder" sender:self];
    } else if (indexPath.item == 2) {
        [self performSegueWithIdentifier:@"showMyShop" sender:self];
    } else if (indexPath.item == 3) {
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    } else if (indexPath.item == 4) {
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    }
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
