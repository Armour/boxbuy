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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WaterfallCellView" owner:self options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
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
    [newPriceStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.00 green:0.66 blue:0.16 alpha:1.00] range:NSMakeRange(0, newPriceStr.length)];
    NSMutableAttributedString *str = oldPriceStr;
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" " ]];
    [str appendAttributedString:newPriceStr];
    self.itemPriceLabel.attributedText = str;
}

- (void)setSellerName:(NSString *)name {
    self.sellerNameLabel.text = name;
    self.sellerNameLabel.textColor = [UIColor colorWithRed:0.34 green:0.77 blue:0.97 alpha:1.00];
}

- (void)setSellerState:(NSString *)state {
    self.sellerStatsLabel.text = state;
}

- (void)setSellerPhoto:(UIImage *)photo {
    self.sellerPhotoImageView.image = photo;
}

@end
