//
//  WaterfallCellView.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterfallCellView : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIButton *itemImageButton;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerStatsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sellerPhotoImageView;

- (void)setItemImageWithStringAsync:(NSString *)imageString;
- (void)setItemTitle:(NSString *)title;
- (void)setItemOldPrice:(NSString *)oldPrice NewPrice:(NSString *)newPrice;
- (void)setSellerName:(NSString *)name;
- (void)setSellerState:(NSString *)state;
- (void)setSellerPhotoWithStringAsync:(NSString *)photoString;

@end
