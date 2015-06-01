//
//  MyPickerView.h
//  YunGeZi
//
//  Created by Armour on 5/30/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPickerView : UIView

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) NSArray *pickerData;

- (void)showPickerView;
- (void)hidePickerView;

@end
