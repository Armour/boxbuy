//
//  WaterfallCellView.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "WaterfallCellView.h"
#import "WaterfallCellModel.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/UIButton+WebCache.h"
#import "AFHTTPRequestOperationManager.h"
#import "LoginInfo.h"

@interface WaterfallCellView ()

@end


@implementation WaterfallCellView

#pragma mark - Init With Frame

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WaterfallCellView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.00].CGColor;
    }
    return self;
}

#pragma mark - Set Property                        

- (void)setItemImageWithStringAsync:(NSString *)imageString callback:(void (^)(BOOL, CGFloat, CGFloat))callback {
    NSURL *url = [NSURL URLWithString:imageString];
    [self.itemImageButton sd_setBackgroundImageWithURL:url
                                              forState:UIControlStateNormal
                                      placeholderImage:[UIImage imageNamed:@"default_cover"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                                 if (error) {
                                                     callback(NO, 0, 0);
                                                 } else {
                                                     callback(YES, image.size.width, image.size.height);
                                                 }
                                             }];
}

- (void)setItemTitle:(NSString *)title {
    self.itemTitleButton.titleLabel.numberOfLines = 3;
    self.itemTitleButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.itemTitleButton setTitle:title forState:UIControlStateNormal];
    [self.itemTitleButton layoutIfNeeded];
    self.titleButtonHeightConstraint.constant = self.itemTitleButton.titleLabel.frame.size.height;
}

- (void)setItemOldPrice:(NSString *)oldPrice NewPrice:(NSString *)newPrice {
    NSMutableAttributedString *oldPriceStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@", oldPrice]];
    [oldPriceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, oldPriceStr.length)];
    [oldPriceStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, oldPriceStr.length)];
    [oldPriceStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, oldPriceStr.length)];
    NSMutableAttributedString *newPriceStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@元", newPrice]];
    [newPriceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, oldPriceStr.length)];
    [newPriceStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.00 green:0.66 blue:0.16 alpha:1.00] range:NSMakeRange(0, newPriceStr.length)];
    if ([oldPrice isEqualToString:newPrice]) {
        NSMutableAttributedString *str = newPriceStr;
        self.itemPriceLabel.attributedText = str;
    } else {
        NSMutableAttributedString *str = oldPriceStr;
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" " ]];
        [str appendAttributedString:newPriceStr];
        self.itemPriceLabel.attributedText = str;
    }
}

- (void)setSellerName:(NSString *)name {
    [self.sellerNameButton setTitle:name forState:UIControlStateNormal];
    [self.sellerNameButton setTitleColor:[UIColor colorWithRed:0.34 green:0.77 blue:0.97 alpha:1.00] forState:UIControlStateNormal];
}

- (void)setSellerIntro:(NSString *)intro {
    self.sellerIntroLabel.text = intro;
}

- (void)setSellerPhotoWithStringAsync:(NSString *)photoString {
    NSURL *url = [NSURL URLWithString:photoString];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.sellerPhotoImageButton.layer.bounds.size.width / 2,
                                                                       self.sellerPhotoImageButton.layer.bounds.size.height / 2)
                                                    radius:self.sellerPhotoImageButton.layer.bounds.size.height / 2
                                                startAngle:0.0
                                                  endAngle:M_PI * 2.0
                                                 clockwise:YES].CGPath;
    self.sellerPhotoImageButton.layer.mask = maskLayer;
    [self.sellerPhotoImageButton sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_headicon"]];
}

@end
