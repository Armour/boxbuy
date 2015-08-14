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

#define SEARCHHISTORY_CELL @"searchHistoryCell"

@interface SearchViewController ()

@property (strong, nonatomic) UISearchBar *categorySearchBar;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSMutableArray *searchHistory;
@property (weak, nonatomic) IBOutlet UITableView *searchHistoryTableView;

- (NSManagedObjectContext *)managedObjectContext;

@end


@implementation SearchViewController

#pragma mark - Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"搜索界面"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self prepareMySearchBar];
    [self refreshSearchHistory];

    /*NSManagedObjectContext * context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SearchHistory" inManagedObjectContext:context];
    NSManagedObject *searchHistory = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    [searchHistory setValue:@"哈哈哈" forKey:@"title"];
    [searchHistory setValue:[NSDate date] forKey:@"time"];
    NSError *error = nil;
    if (![searchHistory.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
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
            NSLog(@"%@", result);
            if (result.count > 0) {
                for (int i = 0; i < result.count; i++) {
                    NSManagedObject *history = (NSManagedObject *)[result objectAtIndex:i];
                    NSLog(@"1 - %@", history);
                    NSLog(@"%@ %@", [history valueForKey:@"title"], [history valueForKey:@"time"]);
                    NSLog(@"2 - %@", history);
                }
            }
        }
        NSManagedObject *searchHistory = (NSManagedObject *)[result objectAtIndex:0];
        [searchHistory setValue:@30 forKey:@"age"];
        NSError *saveError = nil;
        if (![searchHistory.managedObjectContext save:&saveError]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", saveError, saveError.localizedDescription);
        }
    }*/
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索界面"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Init SearchHistoryTableView

- (void)initTableView {
    [self.searchHistoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SEARCHHISTORY_CELL];
    self.searchHistoryTableView.delegate = self;
    self.searchHistoryTableView.dataSource = self;
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
        [self performSegueWithIdentifier:@"showSearchResult" sender:self];
        [self insertSearchQueryToCoreData];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchQuery = [self.searchHistory objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
    [self insertSearchQueryToCoreData];
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
