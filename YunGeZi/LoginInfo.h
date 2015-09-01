//
//  LoginInfo.h
//  YunGeZi
//
//  Created by Chujie Zeng on 8/18/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface LoginInfo : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSString *expireTime;
@property (strong, readonly, nonatomic) NSString *userid;
@property (strong, readonly, nonatomic) NSString *nickname;
@property (strong, readonly, nonatomic) NSString *intro;
@property (strong, readonly, nonatomic) NSString *photoUrlString;
@property (strong, readonly, nonatomic) NSString *photoUrlOriString;
@property (strong, readonly, nonatomic) NSString *schoolId;
@property (strong, readonly, nonatomic) NSString *authstate;
@property (readonly, nonatomic) NSInteger numOfFollow;
@property (readonly, nonatomic) NSInteger numOfFan;
@property (readonly, nonatomic) NSInteger numOfItem;
@property (readonly, nonatomic) NSInteger numOfNewMsg;
@property (readonly, nonatomic) NSInteger numOfMsgSend;
@property (readonly, nonatomic) NSInteger numOfMsgRecv;
@property (nonatomic) BOOL searchViewIsDisappeared;
@property (nonatomic) BOOL categoryViewIsDisappeared;


+ (LoginInfo *)sharedInfo;

- (void)updateWithAccessToken:(NSString *)accessToken
                 refreshToken:(NSString *)refreshToken
                   expireTime:(NSString *)expireTime;

- (void)updateToken;
- (NSString *)schoolNameWithSchoolId:(NSString *)schoolid;
- (NSString *)locationNameWithSchoolId:(NSString *)schoolid withLocationId:(NSString *)locationid;
- (void)refreshSharedUserInfo;
- (void)refreshSharedSchoolInfo;
- (void)refreshSharedCategoryInfo;

@end
