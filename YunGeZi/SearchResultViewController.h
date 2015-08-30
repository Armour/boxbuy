//
//  SearchInCategoryViewController.h
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBStoreHouseRefreshControl.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface SearchResultViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>

@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) CBStoreHouseRefreshControl *storeHouseRefreshControl;
                   
@end
