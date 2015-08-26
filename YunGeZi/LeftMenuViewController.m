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
#import "AFHTTPRequestOperationManager.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "LoginInfo.h"

#define DegreesToRadians(x) (M_PI * x / 180.0)
#define ARROW_ROTATION_ANIMATION @"ArrowRotationAnimation"

@interface LeftMenuViewController ()

@property (strong, nonatomic) NSArray *models;
@property (strong, nonatomic) NSString *selectedItem;
@property (strong, nonatomic) NSString *schoolId;
@property (strong, nonatomic) RATreeView *treeView;
@property (weak, nonatomic) IBOutlet UIButton *schoolNameButton;
@property (weak, nonatomic) IBOutlet UIButton *schoolConfigButton;
@property (weak, nonatomic) IBOutlet UIButton *userImageButton;
@property (weak, nonatomic) IBOutlet UIButton *userProductsButton;
@property (weak, nonatomic) IBOutlet UIButton *userFollowButton;
@property (weak, nonatomic) IBOutlet UIButton *userFansButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet UIButton *userActionButton;
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPaddingConstraint;

@end

@implementation LeftMenuViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self prepareTreeView];
    [self prepareMyNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Init Tree View

- (void)prepareTreeViewModels {
    LeftMenuTreeViewModel *electron = [LeftMenuTreeViewModel modelWithMainClass:@"电子"
                                                                     subClasses:[NSArray arrayWithObjects:@"所有电子", @"手机", @"电脑", @"相机", @"移动存储", @"游戏机", @"平板", @"手环", @"配件", nil]];
    LeftMenuTreeViewModel *cloth = [LeftMenuTreeViewModel modelWithMainClass:@"衣服"
                                                                  subClasses:[NSArray arrayWithObjects:@"所有衣服", @"T恤", @"卫衣", @"衬衫", @"夹克", @"正装",        @"情侣装", @"针织衫", @"羽绒服", @"毛衣", @"棉衣", nil]];
    LeftMenuTreeViewModel *sport = [LeftMenuTreeViewModel modelWithMainClass:@"运动"
                                                                  subClasses:[NSArray arrayWithObjects:@"所有运动", @"球", @"球拍", @"健身器材", @"配件", nil]];
    LeftMenuTreeViewModel *study = [LeftMenuTreeViewModel modelWithMainClass:@"学习"
                                                                  subClasses:[NSArray arrayWithObjects:@"所有学习", @"教材/教辅", @"历年考题", @"考级专用", @"考试用具", @"学霸笔记", @"课外书籍", nil]];
    LeftMenuTreeViewModel *paramedic = [LeftMenuTreeViewModel modelWithMainClass:@"美护"
                                                                      subClasses:[NSArray arrayWithObjects:@"所有美护", @"化妆品", @"美发用品", @"饰品", @"洗浴用品", @"保暖品", @"保健品", nil]];
    LeftMenuTreeViewModel *play = [LeftMenuTreeViewModel modelWithMainClass:@"玩乐"
                                                                 subClasses:[NSArray arrayWithObjects:@"所有玩乐", @"游戏机", @"桌游牌", @"装饰品", @"玩偶", @"玩具", @"游戏配件", @"乐器", @"乐器配件", nil]];
    LeftMenuTreeViewModel *bag = [LeftMenuTreeViewModel modelWithMainClass:@"箱包"
                                                                subClasses:[NSArray arrayWithObjects:@"所有箱包", @"双肩包", @"单肩包", @"钱包", @"托运箱", @"拉杆箱", @"情侣包", @"箱包配件", nil]];
    LeftMenuTreeViewModel *shoes = [LeftMenuTreeViewModel modelWithMainClass:@"鞋子"
                                                                  subClasses:[NSArray arrayWithObjects:@"所有鞋子", @"休闲鞋", @"高跟鞋", @"正装鞋", @"板鞋", @"帆布鞋", @"凉鞋", @"靴子", @"拖鞋", @"棉鞋", @"情侣鞋", nil]];
    LeftMenuTreeViewModel *furniture = [LeftMenuTreeViewModel modelWithMainClass:@"家居"
                                                                      subClasses:[NSArray arrayWithObjects:@"所有家居", @"电器", @"办公用品", @"床上用品", @"餐具", @"清洁用品", @"挂饰/壁饰", @"收纳", @"装修用品", @"装饰摆件", @"浴室用品", nil]];
    LeftMenuTreeViewModel *food = [LeftMenuTreeViewModel modelWithMainClass:@"食饮"
                                                                 subClasses:[NSArray arrayWithObjects:@"所有食饮", @"酒品", @"特产", @"方便速食", @"药剂", @"饮料", @"糕点", @"糖果/巧克力", @"坚果/蜜饯", @"营养品", @"保健品", @"其他", nil]];
    LeftMenuTreeViewModel *virtual = [LeftMenuTreeViewModel modelWithMainClass:@"非实物"
                                                                    subClasses:[NSArray arrayWithObjects:@"所有非实物", @"租赁", @"账号", @"劳力", @"其他", nil]];
    LeftMenuTreeViewModel *vehicle = [LeftMenuTreeViewModel modelWithMainClass:@"交通工具"
                                                                      subClasses:[NSArray arrayWithObjects:@"所有交通工具", @"自行车", @"电动车", @"滑板/轮滑", @"汽车", nil]];

    self.models = [NSArray arrayWithObjects:electron, cloth, sport, study, paramedic, play, bag, shoes, furniture, food, virtual, vehicle, nil];
    self.selectedItem = @"";
}

- (void)prepareTreeView {
    [self prepareTreeViewModels];
    self.categoryView.clipsToBounds = TRUE;
    [self.userInfoView setBackgroundColor:[UIColor clearColor]];
    [self.categoryView setBackgroundColor:[UIColor clearColor]];
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    self.topPaddingConstraint.constant = screenHeight * 0.12;
    self.rightPaddingConstraint.constant = - screenWidth * 0.24;
    self.bottomPaddingConstraint.constant = screenHeight * 0.15;
    self.leftPaddingConstraint.constant = screenWidth * 0.03;
    [self.categoryView layoutIfNeeded];
    self.treeView = [[RATreeView alloc] initWithFrame:CGRectMake(-5, 0, self.categoryView.bounds.size.width, self.categoryView.bounds.size.height)];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    self.treeView.rowsCollapsingAnimation = RATreeViewRowAnimationFade;
    self.treeView.rowsExpandingAnimation = RATreeViewRowAnimationFade;
    self.treeView.backgroundColor = [UIColor clearColor];
    [self.categoryView addSubview:self.treeView];
}

#pragma mark - Notification

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInfo)
                                                 name:@"PostLoingTokenFromRootToLeftMenu"
                                               object:nil];
}

- (void)updateUserInfo {
    [self.userProductsButton setTitle:[[NSString alloc] initWithFormat:@"%ld\r\n商品", (long)[LoginInfo sharedInfo].numOfItem]
                             forState:UIControlStateNormal];
    [self.userFollowButton setTitle:[[NSString alloc] initWithFormat:@"%ld\r\n关注", (long)[LoginInfo sharedInfo].numOfFollow]
                           forState:UIControlStateNormal];
    [self.userFansButton setTitle:[[NSString alloc] initWithFormat:@"%ld\r\n粉丝",(long)[LoginInfo sharedInfo].numOfFan]
                         forState:UIControlStateNormal];
    [self.userNameButton setTitle:[LoginInfo sharedInfo].nickname forState:UIControlStateNormal];
    self.schoolId = [LoginInfo sharedInfo].schoolId;
    [self setUserSchoolName];
    [self.userImageButton sd_setBackgroundImageWithURL:[[NSURL alloc] initWithString:[LoginInfo sharedInfo].photoUrlString]
                                              forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_headicon"]];
    self.userImageButton.layer.cornerRadius = self.userImageButton.bounds.size.height / 2.f;
    self.userImageButton.clipsToBounds = YES;
    self.userProductsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.userFollowButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.userFansButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.userImageButton addTarget:self action:@selector(segueToUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.userProductsButton addTarget:self action:@selector(segueToUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.userFollowButton addTarget:self action:@selector(segueToUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.userFansButton addTarget:self action:@selector(segueToUserInfo) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUserSchoolName {
    [self.schoolNameButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"schoolName"] forState:UIControlStateNormal];
    [self.schoolNameButton addTarget:self action:@selector(segueToChangeSchool) forControlEvents:UIControlEventTouchUpInside];
    [self.schoolConfigButton addTarget:self action:@selector(segueToChangeSchool) forControlEvents:UIControlEventTouchUpInside];
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

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]])
        return 25;
    return 40;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]])
        return 2;
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    UITableViewCell *cell = nil;
    if ([item isKindOfClass:[LeftMenuTreeViewModel class]]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"First Level Cell"];
        cell.textLabel.text = [(LeftMenuTreeViewModel *)item mainClass];
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = [(LeftMenuTreeViewModel *)item subClassString];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(0, 0, 32, 32)];
        [btn setBackgroundImage:[UIImage imageNamed:@"arrow-forward"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(accessoryButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = btn;
        if ([self.selectedItem isEqualToString:[item mainClass]])
            [cell.accessoryView.layer addAnimation:[self arrowRotationAnimationWithFromValue:0.f toValue:90.f duration:0.01f] forKey:ARROW_ROTATION_ANIMATION];
    } else if ([item isKindOfClass:[NSString class]]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Second Level Cell"];
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@", item];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    if ([item isKindOfClass:[LeftMenuTreeViewModel class]]) {
        UITableViewCell *cell = [self.treeView cellForItem:item];
        if ([self.selectedItem isEqualToString:@""]) {
            [cell.accessoryView.layer addAnimation:[self arrowRotationAnimationWithFromValue:0.f toValue:90.f duration:0.3f] forKey:ARROW_ROTATION_ANIMATION];
            self.selectedItem = [item mainClass];
        } else if ([self.selectedItem isEqualToString:[item mainClass]]) {
            [cell.accessoryView.layer addAnimation:[self arrowRotationAnimationWithFromValue:90.f toValue:0.f duration:0.3f] forKey:ARROW_ROTATION_ANIMATION];
            self.selectedItem = @"";
        } else {
            [cell.accessoryView.layer addAnimation:[self arrowRotationAnimationWithFromValue:0.f toValue:90.f duration:0.3f] forKey:ARROW_ROTATION_ANIMATION];
            NSString *tmp = self.selectedItem;
            self.selectedItem = [item mainClass];
            for (int i = 0; i < [self.models count]; i++) {
                if ([tmp isEqualToString:[[self.models objectAtIndex:i] mainClass]]) {
                    id item2 = [self treeView:self.treeView child:i ofItem:nil];
                    UITableViewCell *cell2 = [self.treeView cellForItem:item2];
                    [cell2.accessoryView.layer addAnimation:[self arrowRotationAnimationWithFromValue:90.f toValue:0.f duration:0.3f] forKey:ARROW_ROTATION_ANIMATION];
                    [self.treeView collapseRowForItem:item2 collapseChildren:YES withRowAnimation:RATreeViewRowAnimationFade];
                }
            }
        }
    } else if ([item isKindOfClass:[NSString class]]) {
        // TODO ...
    }
}

- (void)accessoryButtonTouchUpInside:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    id item = [self.treeView itemForCell:cell];
    if ([item isKindOfClass:[LeftMenuTreeViewModel class]]) {
        if ([self.selectedItem isEqualToString:[item mainClass]])
            [self.treeView collapseRowForItem:item collapseChildren:YES withRowAnimation:RATreeViewRowAnimationFade];
        else
            [self.treeView expandRowForItem:item expandChildren:YES withRowAnimation:RATreeViewRowAnimationFade];
        [self.treeView selectRowForItem:item animated:YES scrollPosition:RATreeViewScrollPositionNone];
        [self treeView:self.treeView didSelectRowForItem:item];
    }
}

#pragma mark - Arrow Animation

- (CABasicAnimation *)arrowRotationAnimationWithFromValue:(CGFloat)fromAngle
                                                  toValue:(CGFloat)toAngle
                                                 duration:(CGFloat)duration  {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromAngle * (M_PI / 180.f)];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toAngle * (M_PI / 180.f)];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = 1;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [rotationAnimation setValue:@"ArrowRotation" forKey:ARROW_ROTATION_ANIMATION];
    return rotationAnimation;
}

#pragma mark - Segue Detail

- (void)segueToUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SideMenuToAccountInfo" object:self userInfo:nil];
}

- (void)segueToChangeSchool {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SideMenuToChangeSchool" object:self userInfo:nil];
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