//
//  CategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "DeviceDetect.h"
#import "MobClick.h"
#import "DeviceDetect.h"
#import "AFHTTPRequestOperationManager.h"

#define SEARCHHISTORY_CELL @"searchHistoryCell"

@interface SearchViewController ()

@property (strong, nonatomic) UISearchBar *categorySearchBar;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSMutableArray *searchHistory;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *searchHistoryTableView;
@property (weak, nonatomic) IBOutlet UIView *hotSearchsView;
@property (nonatomic) NSUInteger preferredFontSize;
@property (nonatomic) NSUInteger preferredHotSearchCount;

@end


@implementation SearchViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self prepareMyFont];
    [self prepareMyIndicator];
    [self prepareMySearchBar];
    [self initHotSearchsView];
    [self refreshSearchHistory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"搜索界面"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索界面"];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Prepare Font 

- (void)prepareMyFont {
    if (IS_IPHONE_6) {
        self.preferredFontSize = 14;
        self.preferredHotSearchCount = 5;
    } else if (IS_IPHONE_6P) {
        self.preferredFontSize = 15;
        self.preferredHotSearchCount = 5;
    } else if (IS_IPHONE_5) {
        self.preferredFontSize = 13;
        self.preferredHotSearchCount = 4;
    }
}

#pragma mark - Init HotSearchsView

- (void)initHotSearchsView {
    [self.activityIndicator startAnimating];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://v2.api.uboxs.com/getHottestSearch"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id response) {
             NSMutableArray *hotSearchs = [NSMutableArray array];
             for (id obj in response)
                 [hotSearchs addObject:obj];
             CGFloat viewWidth = self.hotSearchsView.frame.size.width;
             CGFloat viewHeight = self.hotSearchsView.frame.size.height;
             CGFloat labelPadding = 4;
             UIFont *font = [UIFont systemFontOfSize:self.preferredFontSize];

             NSInteger count = [hotSearchs count];
             NSInteger number = count < self.preferredHotSearchCount ? count : self.preferredHotSearchCount;   // Number of Labels will be added into view
             // Will be counted after
             NSMutableArray *hotSearchsTextWidth = [NSMutableArray arrayWithCapacity:number];
             CGFloat sumOfWidth = 0;
             for (NSInteger idx = 0; idx < number; idx++) {
                 NSString *text = hotSearchs[idx];
                 CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName : font}];
                 sumOfWidth += textSize.width + labelPadding;
                 if (sumOfWidth > viewWidth) {
                     number = idx;
                 }
                 hotSearchsTextWidth[idx] = @(textSize.width);
             }

             CGFloat x = 0;
             CGFloat extraWidth = (viewWidth - sumOfWidth + labelPadding) / number;
             for (NSInteger idx = 0; idx < number; idx++) {
                 CGRect frame = CGRectMake(x,
                                           0,
                                           [hotSearchsTextWidth[idx] floatValue] + extraWidth,
                                           viewHeight);
                 UIButton *_button = [[UIButton alloc] initWithFrame:frame];
                 _button.backgroundColor = [UIColor whiteColor];
                 _button.layer.borderColor = [UIColor grayColor].CGColor;
                 _button.layer.borderWidth = 0.5;
                 [_button setTitle:(NSString *)hotSearchs[idx]
                          forState:UIControlStateNormal];
                 [_button setTitleColor:[UIColor blackColor]
                               forState:UIControlStateNormal];
                 _button.titleLabel.textAlignment = NSTextAlignmentCenter;
                 _button.titleLabel.font = font;
                 [_button addTarget:self
                             action:@selector(hotSearchButtonTouchUpInside:)
                   forControlEvents:UIControlEventTouchUpInside];
                 [self.hotSearchsView addSubview:_button];
                 x += frame.size.width + labelPadding;
             }
             [self.activityIndicator stopAnimating];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Fail in Init Hot Search!!!");
             [self initHotSearchsView];
         }];
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setCenter:self.hotSearchsView.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
}

#pragma mark - Init SearchHistoryTableView

- (void)initTableView {
    [self.searchHistoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SEARCHHISTORY_CELL];
    self.searchHistoryTableView.delegate = self;
    self.searchHistoryTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - Core Data

- (void)refreshSearchHistory {
    NSManagedObjectContext * context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchHistory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        self.searchHistory = [[NSMutableArray alloc] init];
        if (result.count > 0) {
            for (int i = 0; i < result.count; i++) {
                NSManagedObject *history = (NSManagedObject *)[result objectAtIndex:i];
                [self.searchHistory addObject:[history valueForKey:@"title"]];
            }
        }
        [self.searchHistoryTableView reloadData];
    }
}

- (void)insertSearchQueryToCoreData {
    // Get Old Search History To Test If Existed
    NSManagedObjectContext * context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchHistory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        if (result.count > 0) {
            for (int i = 0; i < result.count; i++) {
                NSManagedObject *history = (NSManagedObject *)[result objectAtIndex:i];
                if ([[history valueForKey:@"title"] isEqualToString:self.searchQuery]) {
                    // Update Old Search Query
                    [history setValue:[NSDate date] forKey:@"time"];
                    if (![history.managedObjectContext save:&error]) {
                        NSLog(@"Unable to update managed object context.");
                        NSLog(@"%@, %@", error, error.localizedDescription);
                    } else {
                        [self refreshSearchHistory];
                    }
                    return;
                };
            }
        }
    }
    // Insert New Search Query
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SearchHistory" inManagedObjectContext:context];
    NSManagedObject *searchHistory = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    [searchHistory setValue:self.searchQuery forKey:@"title"];
    [searchHistory setValue:[NSDate date] forKey:@"time"];
    if (![searchHistory.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        [self refreshSearchHistory];
    }
}

#pragma mark - Searchbar

- (void)prepareMySearchBar {
    CGFloat width = IS_IPHONE_6 ? 0.80f: IS_IPHONE_6P ? 0.76f : IS_IPHONE_5 ? 0.73f : 0.75f;
    self.categorySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width * width, 44.0f)];
    self.categorySearchBar.delegate = self;
    self.categorySearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor]];
    self.categorySearchBar.placeholder = @"输入您感兴趣的的宝贝";
    self.searchQuery = @"";

    // put the searchbar to searchview into navigationBar
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchView.backgroundColor = [UIColor clearColor];
    [searchView addSubview:self.categorySearchBar];
    self.navigationItem.titleView = searchView;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchQuery = searchBar.text;
    [self.categorySearchBar resignFirstResponder];
    if (![self.searchQuery isEqual: @""]) {
        [self performSearchForSearchQuery];
    } else
        [self popAlert:@"搜索失败" withMessage:@"请输入搜索关键字"];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.categorySearchBar resignFirstResponder];
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

#pragma mark - UICollectionViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchHistory count] < 10? [self.searchHistory count]: 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SEARCHHISTORY_CELL forIndexPath:indexPath];
    cell.textLabel.text = [self.searchHistory objectAtIndex:indexPath.item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchQuery = [self.searchHistory objectAtIndex:indexPath.item];
    [self performSearchForSearchQuery];
}

#pragma mark - Inner Helper

- (void)performSearchForSearchQuery {
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
    [self insertSearchQueryToCoreData];
}

- (void)hotSearchButtonTouchUpInside:(UIButton *)sender {
    self.searchQuery = sender.titleLabel.text;
    [self performSearchForSearchQuery];
}

#pragma mark - ManagedObjectContext

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Segue Detail

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showSearchResult"]){
        SearchResultViewController *controller = (SearchResultViewController *)segue.destinationViewController;
        NSString *urlencodedQuery = [self.searchQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        // Holy shit! Why there need to be encode twice? = = I think the code in website need to be rewrite...
        urlencodedQuery = [urlencodedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [controller setSearchQuery:urlencodedQuery];
    }
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
