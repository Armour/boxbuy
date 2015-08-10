//
//  WaterfallCellView.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  WaterfallCellModel;

@interface WaterfallCellView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *itemImageButton;
@property (weak, nonatomic) IBOutlet UIButton *itemTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *sellerNameButton;
@property (weak, nonatomic) IBOutlet UILabel *sellerStatsLabel;
@property (weak, nonatomic) IBOutlet UIButton *sellerPhotoImageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleButtonHeightConstraint;

- (void)setItemImageWithStringAsync:(NSString *)imageString callback:(void (^)(BOOL succeeded, CGFloat width, CGFloat height))callback;
- (void)setItemTitle:(NSString *)title;
- (void)setItemOldPrice:(NSString *)oldPrice NewPrice:(NSString *)newPrice;
- (void)setSellerName:(NSString *)name;
- (void)setSellerState:(NSString *)state;
- (void)setSellerPhotoWithStringAsync:(NSString *)photoString;

@end
