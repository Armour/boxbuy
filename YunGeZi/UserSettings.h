//
//  UserSettings.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

+ (BOOL)isNotificationEnabled;

+ (BOOL)isSoundNotificationEnabled;

+ (BOOL)isVibrationNotificationEnabled;

+ (void)setNotificationEnabled:(BOOL)value;

+ (void)setSoundNotificationEnabled:(BOOL)value;

+ (void)setVibrationNotificationEnabled:(BOOL)value;

@end
