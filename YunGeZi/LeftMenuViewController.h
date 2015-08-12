//
//  LeftMenuViewController.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "RATreeView.h"

@interface LeftMenuViewController : UIViewController <RESideMenuDelegate, RATreeViewDataSource, RATreeViewDelegate>

@end
