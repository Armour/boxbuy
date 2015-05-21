//
//  CategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "CategoryViewController.h"
#import "MyTabBarController.h"
#import "SearchInCategoryViewController.h"
#import "WebViewJavascriptBridge.h"
#import "CategoryDetailViewController.h"
#import "MobClick.h"

@interface CategoryViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *CategoryWebView;
@property (strong, nonatomic) UISearchBar *categorySearchBar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSString *categoryNumber;
@property WebViewJavascriptBridge* bridge;

@end

@implementation CategoryViewController

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

- (void)addSearchBar {
    self.categorySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*0.027f,0.0f,self.view.bounds.size.width * 0.9f,44.0f)];
    self.categorySearchBar.delegate = self;
    self.categorySearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor]];
    [self.categorySearchBar setPlaceholder:@"输入您想要的宝贝"];

    // put the searchBar to searchView into navigationBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:self.categorySearchBar];
    self.navigationItem.titleView = searchView;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchQuery = searchBar.text;
    [self.categorySearchBar resignFirstResponder];
    if (![self.searchQuery isEqual: @""]) {
        [self performSegueWithIdentifier:@"showSearchResultInCategory" sender:self];
    } else {

    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.categorySearchBar resignFirstResponder];
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
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_CategoryWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        self.categoryNumber = data;
        [self performSegueWithIdentifier:@"showCategoryResult" sender:self];
        responseCallback(self.categoryNumber);
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_CategoryWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addSearchBar];
    [self addIndicator];
    [self loadWebViewRequest];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showSearchResultInCategory"]){
        SearchInCategoryViewController *controller = (SearchInCategoryViewController *)segue.destinationViewController;
        NSString *urlencodedQuery = [self.searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        // Holy shit! Why there need to encode twice? = =
        urlencodedQuery = [urlencodedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [controller setSearchQuery:urlencodedQuery];
    } else if ([segue.identifier isEqualToString:@"showCategoryResult"]){
        CategoryDetailViewController *controller = (CategoryDetailViewController *)segue.destinationViewController;
        [controller setCategoryNumber:self.categoryNumber];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"CategoryPage"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"CategoryPage"];
}

@end
