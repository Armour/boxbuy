//
//  MyTabBarController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyTabBarController.h"
#import "MainPageViewController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

@synthesize access_token = _access_token;

- (NSString *)access_token {
    if (!_access_token) {
        _access_token = [[NSString alloc] init];
    }
    return _access_token;
}

- (void)setAccess_token:(NSString *)access_token {
    _access_token = access_token;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainPageViewController *destination = (MainPageViewController *)[segue destinationViewController];
    destination.access_token = self.access_token;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
