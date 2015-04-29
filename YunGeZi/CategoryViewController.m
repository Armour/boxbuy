//
//  CategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "CategoryViewController.h"
#import "MyTabBarController.h"

@interface CategoryViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *CategoryWebView;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/statics/class.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_CategoryWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
