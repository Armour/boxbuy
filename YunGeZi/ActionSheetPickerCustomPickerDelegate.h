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
    NSArray *notesToDisplayForKey;
    NSArray *scaleNames;
}

@property (nonatomic, strong) NSString *selectedKey;
@property (nonatomic, strong) NSString *selectedScale;


@end
