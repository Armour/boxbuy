//
//  SellingViewController.h
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellingViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *objectNameTextView;
@property (weak, nonatomic) IBOutlet UITextView *objectContentTextView;
@property (strong, nonatomic) NSString *objectName;
@property (strong, nonatomic) NSString *objectContent;
@property (strong, nonatomic) NSString *objectCategory;
@property (strong, nonatomic) NSString *objectLocation;
@property (strong, nonatomic) NSString *objectQuality;
@property (strong, nonatomic) NSString *objectPrice;
@property (strong, nonatomic) NSString *objectNumber;
@property (strong, nonatomic) NSString *school;

@end
