//
//  MainPageViewController.m
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MainPageViewController.h"
#import "MyTabBarController.h"
#import "SearchInMainViewController.h"
#import "WebViewJavascriptBridge.h"
#import "ObjectDetailViewInMainController.h"
#import "MyNavigationController.h"

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

- (void)addSearchBar {
    self.mainPageSearchBar =[[UISearchBar alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*0.027f,0.0f,self.view.bounds.size.width * 0.9f,44.0f)];
    self.mainPageSearchBar.delegate = self;
    self.mainPageSearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor]];
    [self.mainPageSearchBar setPlaceholder:@"输入您想要的宝贝"];

    // put the searchBar to searchView into navigationBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:self.mainPageSearchBar];
    self.navigationItem.titleView = searchView;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchQuery = searchBar.text;
    [self.mainPageSearchBar resignFirstResponder];
    if (![self.searchQuery isEqual: @""]) {
        [self performSegueWithIdentifier:@"showSearchResultInMain" sender:self];
    } else {

    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.mainPageSearchBar resignFirstResponder];
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
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?access_token=%@&refresh_token=%@&expire_time=%@&login=1", tab.access_token, tab.refresh_token, tab.expire_time];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [self.MainPageWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addSearchBar];
    [self addIndicator];
    [self loadWebViewRequest];
}

-(void)viewDidAppear:(BOOL)animated {
    MyNavigationController * nav = (MyNavigationController *)self.navigationController;
    if (nav.shouldUpdateWebView) {
        [_MainPageWebView reload];
        nav.shouldUpdateWebView = FALSE;
    }
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

- (IBAction)tapMainPageView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSearchResultInMain"]) {
        SearchInMainViewController *controller = (SearchInMainViewController *)segue.destinationViewController;
        NSString *urlencodedQuery = [self.searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        // Holy shit! Why there need to encode twice? = =
        urlencodedQuery = [urlencodedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [controller setSearchQuery:urlencodedQuery];
    } else if([segue.identifier isEqualToString:@"detailFromMain"]) {
        ObjectDetailInMainViewController *controller = (ObjectDetailInMainViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

@end
