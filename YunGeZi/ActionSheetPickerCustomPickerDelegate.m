//
//  ActionSheetPickerCustomPickerDelegate.m
//  ActionSheetPicker
//
//  Created by Armour on 31/05/2015.
//  Copyright (c) 2012 Club 15CC. All rights reserved.
//

#import "ActionSheetPickerCustomPickerDelegate.h"

@implementation ActionSheetPickerCustomPickerDelegate

- (id)init {
    if (self = [super init]) {
        notesToDisplayForKey = @[@"电子", @"运动", @"学习", @"鞋子", @"衣服", @"箱包", @"娱乐", @"交通", @"家居", @"饮食"];
        scaleNames = @[@"手环", @"相机", @"手机", @"移动存储", @"游戏机"];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - ActionSheetCustomPickerDelegate Optional's
/////////////////////////////////////////////////////////////////////////
- (void)configurePickerView:(UIPickerView *)pickerView {
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    NSString *resultMessage;
    if (!self.selectedKey && !self.selectedScale) {
        resultMessage = [NSString stringWithFormat:@"Nothing is selected, inital selections: %@, %@",
                         notesToDisplayForKey[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:0]],
                         scaleNames[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:1]]];
    } else {
        resultMessage = [NSString stringWithFormat:@"%@ %@ selected.", self.selectedKey, self.selectedScale];
    }
    NSLog(@"%@", resultMessage);
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIPickerViewDataSource Implementation
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // Returns
    switch (component) {
        case 0: return [notesToDisplayForKey count];
        case 1: return [scaleNames count];
        default:break;
    }
    return 0;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark UIPickerViewDelegate Implementation
/////////////////////////////////////////////////////////////////////////

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0: return 160.0f;
        case 1: return 160.0f;
        default:break;
    }

    return 0;
}

/*- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
 {
 return
 }
 */
// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: return notesToDisplayForKey[(NSUInteger) row];
        case 1: return scaleNames[(NSUInteger) row];
        default:break;
    }
    return nil;
}

/////////////////////////////////////////////////////////////////////////

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    switch (component) {
        case 0:
            self.selectedKey = notesToDisplayForKey[(NSUInteger) row];
            return;

        case 1:
            self.selectedScale = scaleNames[(NSUInteger) row];
            return;
        default:break;
    }
}

@end
