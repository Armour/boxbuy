//
//  CategoryDetailViewController.h
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBStoreHouseRefreshControl.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface CategoryDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>

@property (strong, nonatomic) NSString *mainCategory;
@property (strong, nonatomic) NSString *subCategory;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) CBStoreHouseRefreshControl *storeHouseRefreshControl;

@end
