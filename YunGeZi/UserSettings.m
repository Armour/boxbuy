//
//  UserSettings.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "UserSettings.h"
#import <CoreData/CoreData.h>

#define NOTIFICATION_KEY            @"NotificationEnablded"
#define SOUND_NOTIFICATION_KEY      @"SoundNotificationEnabled"
#define VIBRATION_NOTIFICATION_KEY  @"VibrationNotificationEnabled"

@interface UserSettings ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation UserSettings

+ (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

+ (void)setNotificationEnabled:(BOOL)value {
    [self.userDefaults setBool:value forKey:NOTIFICATION_KEY];
}

+ (void)setSoundNotificationEnabled:(BOOL)value {
    [self.userDefaults setBool:value forKey:SOUND_NOTIFICATION_KEY];
}

+ (void)setVibrationNotificationEnabled:(BOOL)value {
    [self.userDefaults setBool:value forKey:VIBRATION_NOTIFICATION_KEY];
}

+ (BOOL)isNotificationEnabled {
    return [self.userDefaults boolForKey:NOTIFICATION_KEY];
}

+ (BOOL)isSoundNotificationEnabled {
    return [self.userDefaults boolForKey:SOUND_NOTIFICATION_KEY];
}

+ (BOOL)isVibrationNotificationEnabled {
    return [self.userDefaults boolForKey:VIBRATION_NOTIFICATION_KEY];
}

@end
