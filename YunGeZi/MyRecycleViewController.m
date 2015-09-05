//
//  MyRecycleViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 9/5/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyRecycleViewController.h"
#import "MyRecycleCell.h"

@interface MyRecycleViewController ()

@end

@implementation MyRecycleViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyRecycleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myRecycleCell" forIndexPath:indexPath];
    
    cell.itemImageView.image = [UIImage imageNamed:@"default_headicon"];
    cell.imageView.layer.cornerRadius = 2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 1;
    cell.imageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    cell.scheduledTimeLabel.text = @"12月31日 早上";
    
    cell.launchTimeLabel.text = @"2015年12月29日 12:21";
    
    cell.stateButton.layer.cornerRadius = 2;
    cell.stateButton.layer.masksToBounds = YES;
    cell.stateButton.layer.borderWidth = 1;
    cell.stateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.stateButton.titleLabel.text = @"取消预约";
    
    return cell;
}

@end
