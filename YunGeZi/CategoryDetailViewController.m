//
//  CategoryDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "CategoryDetailViewController.h"

@interface CategoryDetailViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *categoryDetailWebView;

@end

@implementation CategoryDetailViewController

@synthesize categoryNumber = _categoryNumber;

- (NSString *)categoryNumber {
    if (!_categoryNumber) {
        _categoryNumber = [[NSString alloc] init];
    }
    return _categoryNumber;
}

- (void)setCategoryNumber:(NSString *)categoryNumber {
    _categoryNumber = categoryNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?c=%@", self.categoryNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_categoryDetailWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
