//
//  SearchInCategoryViewController.h
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchInCategoryViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSString *objectNumber;

@end
