//
//  RootViewController.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface RootViewController : RESideMenu <RESideMenuDelegate>

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSString *expireTime;

@end
