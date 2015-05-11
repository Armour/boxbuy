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
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
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

+ (NSArray *)category {
    return @[@"箱包", @"鞋子", @"衣服", @"家居", @"学习", @"运动", @"娱乐", @"饮食", @"电子", @"美护", @"非实物", @"交通"];
}

- (void)addIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_categoryDetailWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        self.objectNumber = data;
        [self performSegueWithIdentifier:@"detailFromCategory" sender:self];
        responseCallback(self.objectNumber);
    }];
}

- (void)loadWebViewRequest {
    NSMutableString *title = [[NSMutableString alloc] initWithString:@""];
    NSArray *array = [CategoryDetailViewController category];
    NSInteger index = [self.categoryNumber integerValue] - 20;
    [title appendString:array[index]];
    self.navigationItem.title = title;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?c=%@", self.categoryNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_categoryDetailWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addIndicator];
    [self loadWebViewRequest];
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
