//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyNavigationController.h"
#import "MainPageViewController.h"
#import "SearchInMainViewController.h"
#import "ObjectDetailViewInMainController.h"
#import "WebViewJavascriptBridge.h"
#import "MobClick.h"

@interface MainPageViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *MainPageWebView;
@property (strong, nonatomic) UISearchBar *mainPageSearchBar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSString *objectNumber;
@property WebViewJavascriptBridge* bridge;

@end


@implementation MainPageViewController

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

- (void)prepareMySearchBar {
    self.mainPageSearchBar =[[UISearchBar alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*0.027f,0.0f,self.view.bounds.size.width * 0.9f,44.0f)];
    self.mainPageSearchBar.delegate = self;
    self.mainPageSearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor]];
    [self.mainPageSearchBar setPlaceholder:@"输入您想要的宝贝"];

    // put the searchbar to searchview into navigationBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:self.mainPageSearchBar];
    self.navigationItem.titleView = searchView;
}

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.MainPageWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@", data);
        if ([data isEqualToString:@"auth"]) {
            [self performSegueWithIdentifier:@"showVerification" sender:self];
        } else {
            self.objectNumber = data;
            [self performSegueWithIdentifier:@"detailFromMain" sender:self];
        }
        responseCallback(self.objectNumber);
    }];
}

- (void)loadWebViewRequest {
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool_1_3.html?access_token=%@&refresh_token=%@&expire_time=%@&login=1", tab.access_token, tab.refresh_token, tab.expire_time];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [self.MainPageWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareMySearchBar];
    [self prepareMyIndicator];
    [self addWebViewBridge];
    [self loadWebViewRequest];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchQuery = searchBar.text;
    [self.mainPageSearchBar resignFirstResponder];
    if (![self.searchQuery isEqual: @""]) {
        [self performSegueWithIdentifier:@"showSearchResultInMain" sender:self];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.mainPageSearchBar resignFirstResponder];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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

- (void)viewDidAppear:(BOOL)animated {
    MyNavigationController * nav = (MyNavigationController *)self.navigationController;
    if (nav.shouldUpdateWebView) {          // if need update webview
        [_MainPageWebView reload];
        nav.shouldUpdateWebView = FALSE;
    }
    [super viewDidAppear:animated];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (IBAction)tapMainPageView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSearchResultInMain"]) {
        SearchInMainViewController *controller = (SearchInMainViewController *)segue.destinationViewController;
        NSString *urlencodedQuery = [self.searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        // Holy shit! Why there need to be encode twice? = = I think the code in website need to be rewrite...
        urlencodedQuery = [urlencodedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [controller setSearchQuery:urlencodedQuery];
    } else if([segue.identifier isEqualToString:@"detailFromMain"]) {
        ObjectDetailInMainViewController *controller = (ObjectDetailInMainViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"主页"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"主页"];
}

@end
