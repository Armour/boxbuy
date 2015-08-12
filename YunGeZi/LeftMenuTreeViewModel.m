//
//  LeftMenuTreeViewModel.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "LeftMenuTreeViewModel.h"

@implementation LeftMenuTreeViewModel

#pragma mark - Property Method

- (NSString *)subClassString {
    NSMutableString *string = [NSMutableString string];
    for (NSInteger idx = 0; idx < [self.subClasses count] - 1 ; idx++) {
        [string appendFormat:@"%@/", [self.subClasses objectAtIndex:idx]];
    }
    [string appendString:[self.subClasses lastObject]];
    return string;
}

#pragma mark - Public Methods

- (instancetype)initWithMainClass:(NSString *)mainClass subClasses:(NSArray *)subClasses {
    self.mainClass = mainClass;
    self.subClasses = subClasses;
    return self;
}

+ (instancetype)modelWithMainClass:(NSString *)mainClass subClasses:(NSArray *)subClasses {
    return [[LeftMenuTreeViewModel alloc] initWithMainClass:mainClass subClasses:subClasses];
}

@end
