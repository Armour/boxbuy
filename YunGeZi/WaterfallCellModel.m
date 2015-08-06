//
//  WaterfallCellModel.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "WaterfallCellModel.h"

@implementation WaterfallCellModel

@synthesize imageId;
@synthesize imageHash;
@synthesize itemTitle;
@synthesize itemOldPrice;
@synthesize itemNewPrice;
@synthesize sellerName;
@synthesize sellerState;
@synthesize sellerPhotoId;
@synthesize sellerPhotoHash;

- (NSString *)sizeStringFromSize:(IMAGE_SIZE)size {
    NSString *str = nil;
    switch (size) {
        case IMAGE_SIZE_SMALL:
            str = @"sm";
            break;
        case IMAGE_SIZE_MEDIUM:
            str = @"md";
            break;
        case IMAGE_SIZE_LARGE:
            str = @"lg";
            break;
        case IMAGE_SIZE_XLARGE:
            str = @"xl";
            break;
        case IMAGE_SIZE_ORIGIANL:
            str = @"ori";
            break;
        default:
            break;
    }
    return str;
}

- (NSString *)imagePathWithId:(NSString *)Id Hash:(NSString *)Hash Size:(IMAGE_SIZE)size {
    return [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-%@.jpg", Id, Hash, [self sizeStringFromSize:size]];
}

- (NSString *)imagePathWithSize:(IMAGE_SIZE)size {
    NSString *path = [self imagePathWithId:self.imageId
                                      Hash:self.imageHash
                                      Size:size];
    return path;
}

- (NSString *)photoPathWithSize:(IMAGE_SIZE)size {
    NSString *path = [self imagePathWithId:self.sellerPhotoId
                                      Hash:self.sellerPhotoHash
                                      Size:size];
    return path;
}

@end
