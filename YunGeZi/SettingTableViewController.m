//
//  SettingTableViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SettingTableViewController.h"
#import "UserSettings.h"

@interface SettingTableViewController ()

@property (strong, readonly, nonatomic) UserSettings *userSettings;
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
    [self prepareView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Preparation

- (void)prepareSwitchs {
    self.notificationEnabledSwitch.on = [self.userSettings isNotificationEnabled];
    self.soundNotificationEnabledSwitch.on = [self.userSettings isSoundNotificationEnabled];
    self.vibrationNotificationEnabledSwitch.on = [self.userSettings isVibrationNotificationEnabled];
}

- (void)prepareView {
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new]; // Remove reductant separator line
    self.title = @"设置";
    // TODO
    [self.imageCachedSizeLabel setText:@"1.7MB"];
}

#pragma mark - Action

- (IBAction)notificationEnabledChanged:(UISwitch *)sender {
    [self.userSettings setNotificationEnabled:sender.on];
}

- (IBAction)soundNotificationEnabledChanged:(UISwitch *)sender {
    [self.userSettings setSoundNotificationEnabled:sender.on];
}

- (IBAction)vibrationNotificationEnabledChanged:(UISwitch *)sender {
    [self.userSettings setVibrationNotificationEnabled:sender.on];
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
