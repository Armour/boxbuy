//
//  LeftMenuTreeViewModel.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/12/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeftMenuTreeViewModel : NSObject

@property (strong, nonatomic) NSString *mainClass;
@property (strong, readonly, nonatomic) NSString *subClassString;
@property (strong, nonatomic) NSArray *subClasses;

- (instancetype)initWithMainClass:(NSString *)mainClass subClasses:(NSArray *)subClasses;

+ (instancetype)modelWithMainClass:(NSString *)mainClass subClasses:(NSArray *)subClasses;

@end
