//
//  WaterfallCellView.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "WaterfallCellView.h"

@interface WaterfallCellView ()


@end

@implementation WaterfallCellView

- (void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"WaterfallCellView" owner:self options:nil];
}

- (void)setItemImage:(UIImage *)image {
    self.itemImageView.image = image;
}

- (void)setItemTitle:(NSString *)title {
    self.itemTitleLabel.text = title;
}

- (void)setItemOldPrice:(NSString *)oldPrice NewPrice:(NSString *)newPrice {
    NSMutableAttributedString *oldPriceStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@", oldPrice]];
    [oldPriceStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, oldPriceStr.length)];
    [oldPriceStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, oldPriceStr.length)];
    NSMutableAttributedString *newPriceStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@元", newPrice]];
    [newPriceStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255 green:154 blue:21 alpha:1] range:NSMakeRange(0, newPriceStr.length)];
    NSMutableAttributedString *str = oldPriceStr;
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" " ]];
    [str appendAttributedString:newPriceStr];
    self.itemPriceLabel.attributedText = str;
}

- (void)setSellerName:(NSString *)name {
    self.sellerNameLabel.text = name;
    self.sellerNameLabel.textColor = [UIColor colorWithRed:48 green:198 blue:251 alpha:1];
}

- (void)setSellerState:(NSString *)state {
    self.sellerStatsLabel.text = state;
}

- (void)setSellerPhoto:(UIImage *)photo {
    self.sellerPhotoImageView.image = photo;
}

@end
