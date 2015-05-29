//
//  SellingViewController.h
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellingViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *objectName;
@property (weak, nonatomic) IBOutlet UITextView *objectContent;
@property (strong, nonatomic) NSString *objectCategory;
@property (strong, nonatomic) NSString *objectLocation;
@property (strong, nonatomic) NSString *objectQuality;
@property (strong, nonatomic) NSString *objectPrice;
@property (strong, nonatomic) NSString *objectNumber;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end
