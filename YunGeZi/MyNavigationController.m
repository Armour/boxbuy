//
//  MyNavigationController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end


@implementation MyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationBar.titleTextAttributes = dict;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navibg"]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
