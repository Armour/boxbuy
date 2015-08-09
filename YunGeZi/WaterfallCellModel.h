//
//  WaterfallCellModel.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/6/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    IMAGE_SIZE_SMALL,
    IMAGE_SIZE_MEDIUM,
    IMAGE_SIZE_LARGE,
    IMAGE_SIZE_XLARGE,
    IMAGE_SIZE_ORIGIANL
} IMAGE_SIZE;

@interface WaterfallCellModel : NSObject

@property (nonatomic) NSInteger imageWidth;
@property (nonatomic) NSInteger imageHeight;
@property (strong, nonatomic) NSString *imageId;
@property (strong, nonatomic) NSString *imageHash;
@property (strong, nonatomic) NSString *itemTitle;
@property (strong, nonatomic) NSString *itemOldPrice;
@property (strong, nonatomic) NSString *itemNewPrice;
@property (strong, nonatomic) NSString *sellerName;
@property (strong, nonatomic) NSString *sellerState;
@property (strong, nonatomic) NSString *sellerPhotoId;
@property (strong, nonatomic) NSString *sellerPhotoHash;

- (NSString *)imagePathWithSize:(IMAGE_SIZE)size;
- (NSString *)photoPathWithSize:(IMAGE_SIZE)size;

@end
