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
        level_1 = @[@"电子", @"箱包", @"鞋子", @"衣服", @"家居", @"学习", @"运动", @"玩乐", @"饮食", @"美护", @"非实物", @"交通工具"];
        level_2_0 = @[@"电脑", @"相机", @"手机", @"移动存储", @"游戏机", @"手环", @"配件", @"平板"];
        level_2_1 = @[@"拉杆箱", @"双肩包", @"单肩包", @"箱包配件", @"托运箱", @"钱包", @"情侣包"];
        level_2_2 = @[@"休闲鞋", @"高跟鞋", @"情侣鞋", @"正装鞋", @"帆布鞋", @"板鞋", @"拖鞋", @"凉鞋", @"棉鞋", @"靴子"];
        level_2_3 = @[@"T恤", @"卫衣", @"夹克", @"棉衣", @"衬衫", @"针织衫", @"毛衣", @"羽绒服", @"情侣装", @"正装", @"运动装"];
        level_2_4 = @[@"餐具", @"装修用品", @"床上用品", @"办公用品", @"装饰摆件", @"挂饰/壁饰", @"收纳", @"电器", @"清洁用品", @"浴室用品"];
        level_2_5 = @[@"教材/教辅", @"历年考题", @"学霸笔记", @"考试专用", @"课外书籍", @"考试用具"];
        level_2_6 = @[@"球拍", @"球", @"配件", @"健身器材"];
        level_2_7 = @[@"桌游牌", @"游戏机", @"玩具", @"玩偶", @"装饰品", @"乐器", @"游戏配件", @"乐器配件"];
        level_2_8 = @[@"坚果/蜜饯", @"糖果/巧克力", @"糕点", @"方便速食", @"营养品", @"饮料", @"药剂", @"特产", @"保健品", @"酒品", @"其他"];
        level_2_9 = @[@"化妆品", @"保暖品", @"保健品", @"洗浴用品", @"美发用品", @"饰品"];
        level_2_10 = @[@"租赁", @"劳力", @"账号", @"其他"];
        level_2_11 = @[@"滑板轮滑", @"自行车", @"电动车", @"汽车"];
        level_2_display = level_2_0;
    }
    return self;
}

#pragma mark - ActionSheetCustomPickerDelegate Optional's

- (void)configurePickerView:(UIPickerView *)pickerView {
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    if (!self.selectedKey)
        self.selectedKey = level_1[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:0]];
    if (!self.selectedScale)
        self.selectedScale = level_2_display[(NSUInteger) [(UIPickerView *) actionSheetPicker.pickerView selectedRowInComponent:1]];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedKey, @"0", self.selectedScale, @"1", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CategorySelectFinished" object:self userInfo:dict];
}


#pragma mark - UIPickerViewDataSource Implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // Returns
    switch (component) {
        case 0: return [level_1 count];
        case 1: return [level_2_display count];
        default:break;
    }
    return 0;
}

#pragma mark UIPickerViewDelegate Implementation

// returns width of column and height of row for each component.
/*- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0: return 160.0f;
        case 1: return 160.0f;
        default:break;
    }

    return 0;
}*/

// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: return level_1[(NSUInteger) row];
        case 1: return level_2_display[(NSUInteger) row];
        default:break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Row %li selected in component %li", (long)row, (long)component);
    switch (component) {
        case 0:
            self.selectedKey = level_1[(NSUInteger) row];
            switch (row) {
                case 0:
                    level_2_display = level_2_0;
                    break;
                case 1:
                    level_2_display = level_2_1;
                    break;
                case 2:
                    level_2_display = level_2_2;
                    break;
                case 3:
                    level_2_display = level_2_3;
                    break;
                case 4:
                    level_2_display = level_2_4;
                    break;
                case 5:
                    level_2_display = level_2_5;
                    break;
                case 6:
                    level_2_display = level_2_6;
                    break;
                case 7:
                    level_2_display = level_2_7;
                    break;
                case 8:
                    level_2_display = level_2_8;
                    break;
                case 9:
                    level_2_display = level_2_9;
                    break;
                case 10:
                    level_2_display = level_2_10;
                    break;
                case 11:
                    level_2_display = level_2_11;
                    break;

                default:
                    break;
            }

            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView reloadComponent:1];
            return;

        case 1:
            self.selectedScale = level_2_display[(NSUInteger) row];
            return;

        default:
            break;
    }
}

@end
