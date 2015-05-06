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

@interface MainPageViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *MainPageWebView;
@property (strong, nonatomic) UISearchBar *mainPageSearchBar;
@property (strong, nonatomic) NSString *searchQuery;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainPageSearchBar =[[UISearchBar alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*0.027f,0.0f,self.view.bounds.size.width * 0.9f,44.0f)];
    self.mainPageSearchBar.delegate = self;
    self.mainPageSearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor]];
    [self.mainPageSearchBar setPlaceholder:@"输入您想要的宝贝"];

    // put the searchBar to searchView into navigationBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:self.mainPageSearchBar];
    self.navigationItem.titleView = searchView;

    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?access_token=%@&refresh_token=%@&expire_time=%@&login=1", tab.access_token, tab.refresh_token, tab.expire_time];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_MainPageWebView loadRequest:request];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.mainPageSearchBar resignFirstResponder];
    self.searchQuery = searchBar.text;
    [self performSegueWithIdentifier:@"showSearchResultInMain" sender:self];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.mainPageSearchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showSearchResultInMain"]){
        SearchInMainViewController *controller = (SearchInMainViewController *)segue.destinationViewController;
        NSLog(@"%@",self.searchQuery);
        [controller setSearchQuery:self.searchQuery];
    }
}

@end
