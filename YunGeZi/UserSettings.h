//
//  UserSettings.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (readonly, nonatomic) BOOL isNotificationEnabled;
@property (readonly, nonatomic) BOOL isSoundNotificationEnabled;
@property (readonly, nonatomic) BOOL isVibrationNotificationEnabled;

- (void)setNotificationEnabled:(BOOL)value;

- (void)setSoundNotificationEnabled:(BOOL)value;

- (void)setVibrationNotificationEnabled:(BOOL)value;

@end
