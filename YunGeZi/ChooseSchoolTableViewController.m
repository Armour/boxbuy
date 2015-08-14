//
//  ChooseSchoolTableViewController.m
//  
//
//  Created by Armour on 8/9/15.
//
//

#import "ChooseSchoolTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ChooseSchoolTableViewCell.h"

@interface ChooseSchoolTableViewController ()

@property (strong, nonatomic) NSDictionary *schools;
@property (strong, nonatomic) NSDictionary *schoolsId;
@property (strong, nonatomic) NSArray *schoolSectionTitles;
@property (strong, nonatomic) NSArray *schoolIndexTitles;
@property (strong, nonatomic) NSArray *schoolImage;
@property (strong, nonatomic) NSMutableSet *indexPathFetchedImageSet;

@end


@implementation ChooseSchoolTableViewController

@synthesize schools;
@synthesize schoolsId;
@synthesize schoolSectionTitles;
@synthesize schoolIndexTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://v2.api.boxbuy.cc/getSchools"
      parameters:@{@"json":@1}
         success:^(AFHTTPRequestOperation *operation, id response) {
             NSLog(@"Get School Success!!");
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Get School Fail!!");
         }];
    schools = @{@"H" : @[@"杭州电子科技大学", @"杭州师范大学"],
                @"Z" : @[@"浙江财经大学", @"浙江传媒学院", @"浙江大学", @"浙江大学城市学院", @"浙江工商大学", @"浙江工业大学",@"浙江经贸职业技术学院", @"浙江科技学院", @"浙江理工大学", @"浙江树人大学", @"中国计量学院", @"中国美术学院" ]};
    schoolsId = @{@"H" : @[@"2", @"3"],
                  @"Z" : @[@"5", @"6", @"1", @"7", @"8", @"9", @"12", @"13", @"14", @"15", @"17", @"18"]};
    schoolIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    schoolSectionTitles = [[schools allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.indexPathFetchedImageSet = [NSMutableSet set];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    //cell.textLabel.text = school;
    [cell.logoImage sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error || [self.indexPathFetchedImageSet containsObject:indexPath]) {
                return;
            }
            [self.indexPathFetchedImageSet addObject:indexPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        }];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return schoolIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [schoolSectionTitles indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseSchoolTableViewCell *cell = (ChooseSchoolTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.choosenMarkImage.image = [UIImage imageNamed:@"checkmark"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseSchoolTableViewCell *cell = (ChooseSchoolTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.choosenMarkImage.image = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
