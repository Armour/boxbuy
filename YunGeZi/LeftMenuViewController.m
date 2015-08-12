//
//  LeftMenuViewController.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LeftMenuTreeViewModel.h"
#import "RootViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RATreeView.h"

@interface LeftMenuViewController ()

@property (strong, nonatomic) NSArray *models;
@property (strong, nonatomic) RATreeView *treeView;

@end

@implementation LeftMenuViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self prepareTreeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Tree View

- (void)prepareTreeViewModels {
    LeftMenuTreeViewModel *electronicProduct = [LeftMenuTreeViewModel modelWithMainClass:@"电子"
                                                                              subClasses:[NSArray arrayWithObjects:@"手机",
                                                                                          @"电脑", @"相机", @"移动存储", @"游戏机",
                                                                                          @"平板", @"手环", @"配件", nil]];
    LeftMenuTreeViewModel *cloth = [LeftMenuTreeViewModel modelWithMainClass:@"衣服"
                                                                  subClasses:[NSArray arrayWithObjects:@"T恤", @"卫衣", @"衬衫",
                                                                              @"夹克", @"正装", @"情侣装", @"针织衫", @"羽绒服",
                                                                              @"毛衣", @"棉衣", nil]];
    LeftMenuTreeViewModel *sport = [LeftMenuTreeViewModel modelWithMainClass:@"运动"
                                                                  subClasses:[NSArray arrayWithObjects:@"球", @"球拍",
                                                                              @"健身器材", @"配件", nil]];
    self.models = [NSArray arrayWithObjects:electronicProduct, cloth, sport, nil];
}

- (void)prepareTreeView {
    [self prepareTreeViewModels];
    
    CGFloat leftPadding = 20;
    CGFloat topPadding = 100;
    CGSize viewSize = self.view.bounds.size;
    self.treeView = [[RATreeView alloc] initWithFrame:CGRectMake(leftPadding, topPadding, viewSize.width - leftPadding, viewSize.height - topPadding)];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    self.treeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.treeView];
}

#pragma mark - RATreeView

#pragma mark - RATreeViewDataSource

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.models count];
    }
    if ([item isKindOfClass:[NSString class]]) {
        return 0;
    }
    LeftMenuTreeViewModel *model = item;
    return [model.subClasses count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [self.models objectAtIndex:index];
    }
    if ([item isKindOfClass:[NSString class]]) {
        return nil;
    }
    LeftMenuTreeViewModel *model = item;
    return [model.subClasses objectAtIndex:index];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    //NSInteger level = [treeView levelForCellForItem:item];
    UITableViewCell *cell = nil;
    if ([item isKindOfClass:[LeftMenuTreeViewModel class]]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"First Level Cell"];
        cell.textLabel.text = [(LeftMenuTreeViewModel *)item mainClass];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = [(LeftMenuTreeViewModel *)item subClassString];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    } else if ([item isKindOfClass:[NSString class]]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Second Level Cell"];
        cell.textLabel.text = (NSString *)item;
        cell.textLabel.textColor = [UIColor whiteColor];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.indentationLevel = 100;
    return cell;
}

@end