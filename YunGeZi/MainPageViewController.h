//
//  MainPageViewController.h
//  YunGeZi
//
//  Created by Armour on 4/28/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "CBStoreHouseRefreshControl.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DWBubbleMenuButton.h"

@interface MainPageViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, DWBubbleMenuViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) CBStoreHouseRefreshControl *storeHouseRefreshControl;

@end