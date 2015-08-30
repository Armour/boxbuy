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

@interface SettingTableViewController ()

@property (strong, nonatomic) UserSettings *userSettings;
@property (weak, nonatomic) IBOutlet UISwitch *notificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *soundNotificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationNotificationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UILabel *imageCachedSizeLabel;

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"配置页面"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    // TODO
    [self.imageCachedSizeLabel setText:@"1.7MB"];
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
    NSLog(@"Log Out!!!");
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSLog(@"Segue to Account&Safety");
    } else if (indexPath.section == 1 && indexPath.item == 3) {
        NSLog(@"Clear Image Cache");
    } else if (indexPath.section == 2) {
        NSLog(@"Segue to Help&Feed");
    } else if (indexPath.section == 3) {
        NSLog(@"Segue to AboutUs");
    }
}

@end
