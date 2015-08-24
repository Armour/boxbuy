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
    _cachedInfo = nil;
}

NSDictionary *_cachedInfo;

- (NSDictionary *)cachedInfo {
    if (!_cachedInfo) {
        NSString *urlString = @"http://v2.api.boxbuy.cc/getUserData";
        NSString *postData = [NSString stringWithFormat:@"access_token=%@&userid=me", self.accessToken];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            return nil;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            return nil;
        }
        _cachedInfo = dict;
    }
    return _cachedInfo;
}

- (NSString *)nickname {
    return [NSString stringWithFormat:@"%@",[[self cachedInfo] valueForKeyPath:@"Account.nickname"]];
}

- (NSString *)intro {
    return [[self cachedInfo] valueForKeyPath:@"Account.intro"];
}

- (NSString *)photoUrlString {
    NSString *photoId = [[self cachedInfo] valueForKeyPath:@"Account.headiconid"];
    NSString *photoHash = [[self cachedInfo] valueForKeyPath:@"HeadIcon.hash"];
    NSString *urlString = [NSString stringWithFormat:@"http://img.boxbuy.cc/%@/%@-ori.jpg", photoId, photoHash];
    return urlString;
}

- (NSString *)schoolId {
    return [[self cachedInfo] valueForKeyPath:@"Account.schoolid"];
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
