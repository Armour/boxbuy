//
//  MyPickerView.m
//  YunGeZi
//
//  Created by Armour on 5/30/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyPickerView.h"

@interface MyPickerView() <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation MyPickerView

@synthesize pickerData = _pickerData;

- (NSArray *)pickerData {
    if (!_pickerData) {
        _pickerData = [[NSArray alloc] init];
    }
    return _pickerData;
}

- (void)setPickerData:(NSArray *)pickerData {
    _pickerData = pickerData;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.contentView = [[UIView alloc] init];
        //self.picker = [[UIPickerView alloc] init];
        //[self addSubview:self.contentView];
        //[self.contentView addSubview:self.picker];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)showPickerView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self.contentView setFrame:CGRectMake(0, screenHeight-self.picker.frame.size.height, screenWidth, self.picker.frame.size.height)];
    } completion:^(BOOL isFinished){
        self.userInteractionEnabled = YES;
    }];
}

-(void)hidePickerView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.backgroundColor = [UIColor clearColor];
        [self.contentView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    } completion:^(BOOL isFinished){
        self.userInteractionEnabled = NO;
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *tmp = self.pickerData[component];
    return tmp.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSLog(@"%@",self.pickerData[component][row]);
    return [[NSAttributedString alloc] initWithString:self.pickerData[component][row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

}

@end
