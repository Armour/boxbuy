//
//  CategoryDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "WebViewJavascriptBridge.h"
#import "ObjectDetailInCategoryViewController.h"

@interface CategoryDetailViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *categoryDetailWebView;
@property WebViewJavascriptBridge* bridge;

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

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_categoryDetailWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        self.objectNumber = data;
        [self performSegueWithIdentifier:@"detailFromCategory" sender:self];
        responseCallback(self.objectNumber);
    }];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailFromCategory"]) {
        ObjectDetailInCategoryViewController *controller = (ObjectDetailInCategoryViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

@end