//
//  SearchInMainViewController.m
//  YunGeZi
//
//  Created by Armour on 5/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SearchInMainViewController.h"
#import "WebViewJavascriptBridge.h"
#import "ObjectDetailInMainSearchViewController.h"

@interface SearchInMainViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *searchResultWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation SearchInMainViewController

@synthesize searchQuery = _searchQuery;

- (NSString *)searchQuery {
    if (!_searchQuery) {
        _searchQuery = [[NSString alloc] init];
    }
    return _searchQuery;
}

- (void)setSearchQuery:(NSString *)searchQuery {
    _searchQuery = searchQuery;
}

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_searchResultWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        self.objectNumber = data;
        [self performSegueWithIdentifier:@"detailFromMainSearch" sender:self];
        responseCallback(self.objectNumber);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?q=%@", self.searchQuery];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_searchResultWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailFromMainSearch"]) {
        ObjectDetailInMainSearchViewController *controller = (ObjectDetailInMainSearchViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

@end
