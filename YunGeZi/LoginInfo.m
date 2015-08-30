//
//  LoginInfo.m
//  YunGeZi
//
//  Created by Chujie Zeng on 8/18/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "LoginInfo.h"

@interface LoginInfo ()

@property (strong, readonly, nonatomic) NSDictionary *cachedInfo;

@end


@implementation LoginInfo

@synthesize cachedInfo = _cachedInfo;

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
    [self refreshSharedInfo];
}

#pragma mark- Cached Info

- (NSDictionary *)cachedInfo {
    if (!_cachedInfo) {
        _cachedInfo = [[NSDictionary alloc] init];
    }
    return _cachedInfo;
}

- (void)setCachedInfo:(NSDictionary *)cachedInfo {
    _cachedInfo = cachedInfo;
}

#pragma mark- Refresh Shared Info

- (void)refreshSharedInfo {
    NSString *urlString = @"http://v2.api.boxbuy.cc/getUserData";
    NSString *postData = [NSString stringWithFormat:@"access_token=%@&userid=me", self.accessToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        return;
    }
    _cachedInfo = dict;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CachedInfoRefreshed" object:self userInfo:nil];
}

#pragma mark - Get Info from Cache

- (NSString *)nickname {
    return [NSString stringWithFormat:@"%@",[[self cachedInfo] valueForKeyPath:@"Account.nickname"]];
}

- (NSString *)intro {
    return [[self cachedInfo] valueForKeyPath:@"Account.intro"];
}

- (NSString *)photoUrlString {
    NSString *photoId = [[self cachedInfo] valueForKeyPath:@"Account.headiconid"];
    NSString *photoHash = [[self cachedInfo] valueForKeyPath:@"HeadIcon.hash"];
    NSString *urlString = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-mid.jpg", photoId, photoHash];
    return urlString;
}

- (NSString *)photoUrlOriString {
    NSString *photoId = [[self cachedInfo] valueForKeyPath:@"Account.headiconid"];
    NSString *photoHash = [[self cachedInfo] valueForKeyPath:@"HeadIcon.hash"];
    NSString *urlString = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-ori.jpg", photoId, photoHash];
    return urlString;
}

- (NSString *)schoolId {
    return [[self cachedInfo] valueForKeyPath:@"Account.schoolid"];
}

- (NSString *)authstate {
    return [[self cachedInfo] valueForKeyPath:@"Account.authstate"];
}

- (NSInteger)numOfFollow {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_follow"] integerValue];
}

- (NSInteger)numOfFan {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_fan"] integerValue];
}

- (NSInteger)numOfItem {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_item"] integerValue];
}

- (NSInteger)numOfNewMsg {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_newmsg"] integerValue];
}

- (NSInteger)numOfMsgSend {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_msg_send"] integerValue];
}

- (NSInteger)numOfMsgRecv {
    return [[[self cachedInfo] valueForKeyPath:@"Account.value_msg_recv"] integerValue];
}

@end
