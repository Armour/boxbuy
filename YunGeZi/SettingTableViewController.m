//
//  SettingTableViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SettingTableViewController.h"
#import "UserSettings.h"
#import "MobClick.h"
#import "SDImageCache.h"

@interface SettingTableViewController ()

@property (strong, nonatomic) UserSettings *userSettings;
@property (weak, nonatomic) IBOutlet UISwitch *notificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *soundNotificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationNotificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UILabel *imageCachedSizeLabel;
@property (nonatomic) BOOL logoutMark;

@end

@implementation SettingTableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareSwitchs];
    [self prepareTableView];
    self.userSettings = [[UserSettings alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"配置页面"];
    [self refreshCacheSize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"配置页面"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inner Helper

- (NSString *)notRounding:(float)price afterPoint:(int)position {
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

#pragma mark - Preparation

- (void)prepareSwitchs {
    self.notificationEnabledSwitch.on = [UserSettings isNotificationEnabled];
    self.soundNotificationEnabledSwitch.on = [UserSettings isSoundNotificationEnabled];
    self.vibrationNotificationEnabledSwitch.on = [UserSettings isVibrationNotificationEnabled];
    [self notificationEnabledChanged:self.notificationEnabledSwitch];
}

- (void)prepareTableView {
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new]; // Remove reductant separator line
    self.title = @"设置";
    self.logoutMark = NO;
    [self refreshCacheSize];
}

#pragma mark - Refresh Cache Size

- (void)refreshCacheSize {
    NSString *sizeStr;
    NSInteger size = (unsigned long)[[SDImageCache sharedImageCache] getSize];
    if (size == 0) {
        sizeStr = @"已清空";
    } else if (size < 1024) {
        sizeStr = [[NSString alloc] initWithFormat:@"%ldB", (long)size];
    } else if (size < 1024 * 1024) {
        sizeStr = [[NSString alloc] initWithFormat:@"%@KB", [self notRounding:(long)size/1024.0 afterPoint:1]];
    } else if (size < 1024 * 1024 * 1024) {
        sizeStr = [[NSString alloc] initWithFormat:@"%@MB", [self notRounding:(long)size/(1024.0*1024) afterPoint:1]];
    }
    [self.imageCachedSizeLabel setText:sizeStr];
}

#pragma mark - Action

- (IBAction)notificationEnabledChanged:(UISwitch *)sender {
    [UserSettings setNotificationEnabled:sender.on];
    if (!sender.on) {   // Dirty Code Waiting to be Refactored :)
        self.soundNotificationEnabledSwitch.on = NO;
        self.soundNotificationEnabledSwitch.enabled = NO;
        [self soundNotificationEnabledChanged:self.soundNotificationEnabledSwitch];
        self.vibrationNotificationEnabledSwitch.on = NO;
        self.vibrationNotificationEnabledSwitch.enabled = NO;
        [self vibrationNotificationEnabledChanged:self.vibrationNotificationEnabledSwitch];
    } else {
        self.soundNotificationEnabledSwitch.enabled = YES;
        self.vibrationNotificationEnabledSwitch.enabled = YES;
    }
}

- (IBAction)soundNotificationEnabledChanged:(UISwitch *)sender {
    [UserSettings setSoundNotificationEnabled:sender.on];
}

- (IBAction)vibrationNotificationEnabledChanged:(UISwitch *)sender {
    [UserSettings setVibrationNotificationEnabled:sender.on];
}

- (IBAction)logOutButtonTouchUpInside:(UIButton *)sender {
    self.logoutMark = YES;
    [self popAlertWithDelegate:@"登出" withMessage:@"确定退出此用户么QUQ"];
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSLog(@"Segue to Security");
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    } else if (indexPath.section == 1 && indexPath.item == 3) {
        NSLog(@"Clear Image Cache");
        [self popAlertWithDelegate:@"清除缓存" withMessage:@"确定要清除么~ \r\n (已载入的图片重新载入，会烧流量哦)"];
    } else if (indexPath.section == 2) {
        NSLog(@"Segue to Help&Feed");
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    } else if (indexPath.section == 3) {
        NSLog(@"Segue to AboutUs");
        [self popAlert:@"此功能下版本开放" withMessage:@"敬请期待~"];
    }
}

#pragma Segue Detail

- (void)performLogout {
    [self performSegueWithIdentifier:@"logoutFromConfigPage" sender:self];
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

- (void)popAlertWithDelegate:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:@"取消", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.logoutMark && buttonIndex == 0) {
        [self performLogout];
    } else if (!self.logoutMark && buttonIndex == 0) {
        [[SDImageCache sharedImageCache] clearDisk];
        [self refreshCacheSize];
    } else {
        self.logoutMark = NO;
    }
}

@end
