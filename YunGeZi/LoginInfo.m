//
//  LoginInfo.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/18/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginInfo.h"

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]

@interface LoginInfo ()

@property (strong, readonly, nonatomic) NSDictionary *cachedUserInfo;
@property (strong, readonly, nonatomic) NSDictionary *cachedSchoolInfo;
@property (strong, readonly, nonatomic) NSDictionary *cachedCategoryInfo;
@property (strong, nonatomic) AFHTTPRequestOperationManager *sharedManager;

@end


@implementation LoginInfo

@synthesize cachedUserInfo = _cachedUserInfo;
@synthesize cachedSchoolInfo = _cachedSchoolInfo;
@synthesize cachedCategoryInfo = _cachedCategoryInfo;
@synthesize sharedManager = _sharedManager;

#pragma mark - Shared Info and Update

+ (LoginInfo *)sharedInfo {
    static LoginInfo *_sharedInfo;
    @synchronized(self) {
        if (!_sharedInfo) {
            _sharedInfo = [[LoginInfo alloc] init];
        }
        return _sharedInfo;
    }
}

- (void)updateWithAccessToken:(NSString *)accessToken
                 refreshToken:(NSString *)refreshToken
                   expireTime:(NSString *)expireTime {
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.expireTime = expireTime;
    _sharedManager = [AFHTTPRequestOperationManager manager];
    _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self refreshSharedUserInfo];
    [self refreshSharedSchoolInfo];
    [self refreshSharedCategoryInfo];
}

- (void)updateToken {
    if ([self string:TimeStamp isGreaterThanString:self.expireTime]) {
        [_sharedManager POST:@"https://secure.boxbuy.cc/oauth/refresh"
                  parameters:@{@"refresh_token" : self.refreshToken}
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSError *jsonError = [[NSError alloc] init];
                         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                                  options:NSJSONReadingMutableContainers
                                                                                    error:&jsonError];
                         [self updateWithAccessToken:response[@"access_token"]
                                        refreshToken:response[@"refresh_token"]
                                          expireTime:response[@"expire_time"]];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self updateToken];
                     }];
    }
}

- (BOOL)string:(NSString*)str1 isGreaterThanString:(NSString*)str2 {
    NSArray *a1 = [str1 componentsSeparatedByString:@"."];
    NSArray *a2 = [str2 componentsSeparatedByString:@"."];
    NSInteger totalCount = ([a1 count] < [a2 count]) ? [a1 count] : [a2 count];
    NSInteger checkCount = 0;

    while (checkCount < totalCount) {
        if([a1[checkCount] integerValue] < [a2[checkCount] integerValue])
            return NO;
        else if([a1[checkCount] integerValue] > [a2[checkCount] integerValue])
            return YES;
        else
            checkCount++;
    }
    return NO;
}

#pragma mark- Cached Info

- (NSDictionary *)cachedUserInfo {
    if (!_cachedUserInfo) {
        _cachedUserInfo = [[NSDictionary alloc] init];
    }
    return _cachedUserInfo;
}

- (void)setCachedUserInfo:(NSDictionary *)cachedUserInfo {
    _cachedUserInfo = cachedUserInfo;
}

- (NSDictionary *)cachedSchoolInfo {
    if (!_cachedSchoolInfo) {
        _cachedSchoolInfo = [[NSDictionary alloc] init];
    }
    return _cachedSchoolInfo;
}

- (void)setCachedSchoolInfo:(NSDictionary *)cachedSchoolInfo {
    _cachedSchoolInfo = cachedSchoolInfo;
}

- (NSDictionary *)cachedCategoryInfo {
    if (!_cachedCategoryInfo) {
        _cachedCategoryInfo = [[NSDictionary alloc] init];
    }
    return _cachedCategoryInfo;
}

- (void)setCachedCategoryInfo:(NSDictionary *)cachedCategoryInfo {
    _cachedCategoryInfo = cachedCategoryInfo;
}

#pragma mark- Refresh Shared Info

- (void)refreshSharedUserInfo {
    [_sharedManager POST:@"http://v2.api.boxbuy.cc/getUserData"
       parameters:@{@"access_token" : self.accessToken, @"userid" : @"me"}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *jsonError = [[NSError alloc] init];
              NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&jsonError];
              _cachedUserInfo = response;
              [[NSNotificationCenter defaultCenter] postNotificationName:@"CachedUserInfoRefreshed"
                                                                  object:self
                                                                userInfo:nil];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self refreshSharedUserInfo];
          }];
}

- (void)refreshSharedSchoolInfo {
    [_sharedManager GET:@"http://v2.api.boxbuy.cc/getSchools"
             parameters:@{@"json" : @"1"}
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *jsonError = [[NSError alloc] init];
                    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:&jsonError];
                    _cachedSchoolInfo = response;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CachedSchoolInfoRefreshed"
                                                                         object:self
                                                                       userInfo:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self refreshSharedSchoolInfo];
                }];
}

- (void)refreshSharedCategoryInfo {
    [_sharedManager GET:@"http://v2.api.boxbuy.cc/getItemClasses"
             parameters:@{@"json" : @"1"}
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *jsonError = [[NSError alloc] init];
                    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&jsonError];
                    _cachedCategoryInfo = response;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CachedCategoryInfoRefreshed"
                                                                        object:self
                                                                      userInfo:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self refreshSharedCategoryInfo];
                }];
}

#pragma mark - Get Info from Cache

- (NSString *)userid {
    return [NSString stringWithFormat:@"%@",[[self cachedUserInfo] valueForKeyPath:@"Account.userid"]];
}

- (NSString *)nickname {
    return [NSString stringWithFormat:@"%@",[[self cachedUserInfo] valueForKeyPath:@"Account.nickname"]];
}

- (NSString *)intro {
    return [[self cachedUserInfo] valueForKeyPath:@"Account.intro"];
}

- (NSString *)photoUrlString {
    NSString *photoId = [[self cachedUserInfo] valueForKeyPath:@"Account.headiconid"];
    NSString *photoHash = [[self cachedUserInfo] valueForKeyPath:@"HeadIcon.hash"];
    NSString *urlString = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-md.jpg", photoId, photoHash];
    return urlString;
}

- (NSString *)photoUrlOriString {
    NSString *photoId = [[self cachedUserInfo] valueForKeyPath:@"Account.headiconid"];
    NSString *photoHash = [[self cachedUserInfo] valueForKeyPath:@"HeadIcon.hash"];
    NSString *urlString = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-ori.jpg", photoId, photoHash];
    return urlString;
}

- (NSString *)schoolId {
    return [[self cachedUserInfo] valueForKeyPath:@"Account.schoolid"];
}

- (NSString *)authstate {
    return [[self cachedUserInfo] valueForKeyPath:@"Account.authstate"];
}

- (NSInteger)numOfFollow {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_follow"] integerValue];
}

- (NSInteger)numOfFan {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_fan"] integerValue];
}

- (NSInteger)numOfItem {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_item"] integerValue] > 0? [[[self cachedUserInfo] valueForKeyPath:@"Account.value_item"] integerValue]: 0;
}

- (NSInteger)numOfNewMsg {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_newmsg"] integerValue];
}

- (NSInteger)numOfMsgSend {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_msg_send"] integerValue];
}

- (NSInteger)numOfMsgRecv {
    return [[[self cachedUserInfo] valueForKeyPath:@"Account.value_msg_recv"] integerValue];
}

- (NSString *)schoolNameWithSchoolId:(NSString *)schoolid {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *sid = [formatter numberFromString:schoolid];
    if (sid == nil) {
        return @"";
    }
    for (int i = 0; i < 100; i++) {
        NSString *tmpStr = [[NSString alloc] initWithFormat:@"%d", i];
        if ([_cachedSchoolInfo objectForKey:tmpStr]) {
            NSDictionary *tmpDict = [_cachedSchoolInfo objectForKey:tmpStr];
            if ([tmpDict[@"id"] isEqualToNumber:sid]) {
                return tmpDict[@"nameCh"];
            }
        }
    }
    return @"";
}

- (NSString *)locationNameWithSchoolId:(NSString *)schoolid withLocationId:(NSString *)locationid {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *sid = [formatter numberFromString:schoolid];
    NSNumber *lid = [formatter numberFromString:locationid];
    if (sid == nil || lid == nil) {
        return @"";
    }
    for (int i = 0; i < 100; i++) {
        NSString *tmpStr = [[NSString alloc] initWithFormat:@"%d", i];
        if ([_cachedSchoolInfo objectForKey:tmpStr]) {
            NSDictionary *tmpDict = [_cachedSchoolInfo objectForKey:tmpStr];
            if ([tmpDict[@"id"] isEqualToNumber:sid]) {
                NSArray *tmpArr = tmpDict[@"campus"];
                for (int j = 0; j < [tmpArr count]; j++) {
                    NSDictionary *tmpDict2 = [tmpArr objectAtIndex:j];
                    if ([tmpDict2[@"id"] isEqualToNumber:lid]) {
                        return tmpDict2[@"name"];
                    }
                }
            }
        }
    }
    return @"";
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
