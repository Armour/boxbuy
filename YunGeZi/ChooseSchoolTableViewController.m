//
//  ChooseSchoolTableViewController.m
//  
//
//  Created by Armour on 8/9/15.
//
//

#import "ChooseSchoolTableViewController.h"
#import "ChooseSchoolTableViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "LoginInfo.h"
#import "MobClick.h"

@interface ChooseSchoolTableViewController ()

@property (strong, nonatomic) NSDictionary *schools;
@property (strong, nonatomic) NSDictionary *schoolsId;
@property (strong, nonatomic) NSArray *schoolSectionTitles;
@property (strong, nonatomic) NSArray *schoolIndexTitles;
@property (strong, nonatomic) NSArray *schoolImage;
@property (strong, nonatomic) NSMutableSet *indexPathFetchedImageSet;
@property (strong, nonatomic) NSIndexPath *choosedIndexPath;
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation ChooseSchoolTableViewController

@synthesize schools;
@synthesize schoolsId;
@synthesize schoolSectionTitles;
@synthesize schoolIndexTitles;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSchoolArray];
    [self prepareMyIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"修改学校"];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"修改学校"];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Init School Array 

- (void)initSchoolArray {
    schools = @{@"H" : @[@"杭州电子科技大学", @"杭州师范大学"],
                @"Z" : @[@"浙江财经大学", @"浙江传媒学院", @"浙江大学", @"浙江大学城市学院", @"浙江工商大学", @"浙江工业大学",@"浙江经贸职业技术学院", @"浙江科技学院", @"浙江理工大学", @"浙江树人大学", @"中国计量学院", @"中国美术学院" ]};
    schoolsId = @{@"H" : @[@"2", @"3"],
                  @"Z" : @[@"5", @"6", @"1", @"7", @"8", @"9", @"12", @"13", @"14", @"15", @"17", @"18"]};
    schoolIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    schoolSectionTitles = [[schools allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.indexPathFetchedImageSet = [NSMutableSet set];
    self.choosedIndexPath = nil;
}

#pragma mark - Prepare Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Prepare Loading Mask

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 3 )];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.4;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [schoolSectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [schoolSectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [schoolSectionTitles objectAtIndex:section];
    NSArray *sectionSchools = [schools objectForKey:sectionTitle];
    return [sectionSchools count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseSchoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SchoolCell" forIndexPath:indexPath];
    NSString *sectionTitle = [schoolSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSchools = [schools objectForKey:sectionTitle];
    NSArray *sectionSchoolsId = [schoolsId objectForKey:sectionTitle];
    NSString *school = [sectionSchools objectAtIndex:indexPath.row];
    NSString *schoolId = [sectionSchoolsId objectAtIndex:indexPath.row];
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://static.boxbuy.cc/image/schools/%@/icon.gif", schoolId];
    NSURL *url = [NSURL URLWithString:urlString];
    cell.schoolNameLabel.text = school;
    [cell.logoImage sd_setImageWithURL:url
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (error || [self.indexPathFetchedImageSet containsObject:indexPath]) {
                                     return;
                                 }
                                 [self.indexPathFetchedImageSet addObject:indexPath];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                 });
                             }];
    if ([self.choosedIndexPath isEqual:indexPath])
        cell.choosenMarkImage.image = [UIImage imageNamed:@"checkmark"];
    else
        cell.choosenMarkImage.image = nil;
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return schoolIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [schoolSectionTitles indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.choosedIndexPath = indexPath;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (IBAction)nextButtonTouchUpInside:(UIBarButtonItem *)sender {
    if (self.choosedIndexPath != nil) {
        NSString *sectionTitle = [schoolSectionTitles objectAtIndex:self.choosedIndexPath.section];
        NSArray *sectionSchools = [schools objectForKey:sectionTitle];
        NSArray *sectionSchoolsId = [schoolsId objectForKey:sectionTitle];
        [[NSUserDefaults standardUserDefaults] setObject:[sectionSchoolsId objectAtIndex:self.choosedIndexPath.row] forKey:@"schoolId"];
        [[NSUserDefaults standardUserDefaults] setObject:[sectionSchools objectAtIndex:self.choosedIndexPath.row] forKey:@"schoolName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([[LoginInfo sharedInfo].authstate isEqualToString:@"0"])
            [self popAlertWith2Button:@"设置成功" withMessage:@"现在就认证此学校么"];
        else
            [self popAlert:@"设置成功" withMessage:@"您选择查看此学校的商品~"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"schoolId"];
        [[NSUserDefaults standardUserDefaults] setObject:@"未设置学校" forKey:@"schoolName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self popAlert:@"设置成功" withMessage:@"默认查看全部学校商品，现在开始吧~"];
    }
}

#pragma mark - Alert

- (void)popAlertWith2Button:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
    [alert show];
}

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.choosedIndexPath != nil && [[LoginInfo sharedInfo].authstate isEqualToString:@"0"]) {
        if (buttonIndex == 0 ) {
            [self prepareLoadingMask];
            [self addLoadingMask];
            [self.activityIndicator startAnimating];
            [self.view bringSubviewToFront:self.activityIndicator];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:@"http://v2.api.boxbuy.cc/getSchoolAuthenticationApplyAbility"
               parameters:@{@"schoolid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolId"]}
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      if ([[responseObject valueForKeyPath:@"needCapthcha"] isEqual:@1])
                          [self performSegueWithIdentifier:@"goToUserVerifyWithCapthcha" sender:self];
                      else
                          [self performSegueWithIdentifier:@"goToUserVerify" sender:self];
                      [self removeLoadingMask];
                      [self.activityIndicator stopAnimating];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [self removeLoadingMask];
                      [self.activityIndicator stopAnimating];
                      UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"网络不好"
                                                                     message:@"请稍后重试"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"YES"
                                                           otherButtonTitles:nil];
                      [alert show];
                  }];
        } else {
            [self performSegueWithIdentifier:@"chooseSchoolDone" sender:self];
        }
    } else {
        [self performSegueWithIdentifier:@"chooseSchoolDone" sender:self];
    }
}

@end
