//
//  AccountDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface AccountDetailTableViewController()
;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@end

@implementation AccountDetailTableViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"个人信息"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"个人信息"];
}

#pragma mark - Prepare Item

- (void)prepareItem {
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height / 2;
    self.avatarImageView.clipsToBounds = YES;
    [self.avatarImageView sd_setImageWithURL:[[NSURL alloc] initWithString:[LoginInfo sharedInfo].photoUrlString]
                            placeholderImage:[UIImage imageNamed:@"default_headicon"]];
    [self.nickenameLabel setText:@"立即设置"];
    [self.introLabel setText:@"立即设置"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        //avatar
    } else if (indexPath.item == 1) {
        [self performSegueWithIdentifier:@"showChangeNickname" sender:self];
    } else if (indexPath.item == 2) {
        //intro
    }
}

@end
