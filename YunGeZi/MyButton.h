//
//  MyButton.h
//  YunGeZi
//
//  Created by Armour on 8/25/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton {
    id userData;
}

@property (readwrite, nonatomic, retain) NSString *userData;

@end
