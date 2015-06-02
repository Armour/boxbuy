//
//  ActionSheetPickerCustomPickerDelegate.h
//  YunGeZi
//
//  Created by Armour on 31/05/2015.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetCustomPickerDelegate.h"

@interface ActionSheetPickerCustomPickerDelegate : NSObject <ActionSheetCustomPickerDelegate>
{
    NSArray *level_1;
    NSArray *level_2_0;
    NSArray *level_2_1;
    NSArray *level_2_2;
    NSArray *level_2_3;
    NSArray *level_2_4;
    NSArray *level_2_5;
    NSArray *level_2_6;
    NSArray *level_2_7;
    NSArray *level_2_8;
    NSArray *level_2_9;
    NSArray *level_2_10;
    NSArray *level_2_11;
    NSArray *level_2_display;
}

@property (nonatomic, strong) NSString *selectedKey;
@property (nonatomic, strong) NSString *selectedScale;


@end
