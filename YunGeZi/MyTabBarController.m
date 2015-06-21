//
//  MyTabBarController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "MyTabBarController.h"
#import "MainPageViewController.h"

@interface MyTabBarController ()

@property (weak,nonatomic) NSString *letters;

- (NSString *)randomStringWithLength:(int)len;
- (void)getSchool;

@end

@implementation MyTabBarController

@synthesize access_token = _access_token;
@synthesize refresh_token = _refresh_token;
@synthesize expire_time = _expire_time;

- (NSString *)access_token {
    if (!_access_token) {
        _access_token = [[NSString alloc] init];
    }
    return _access_token;
}

- (void)setAccess_token:(NSString *)access_token {
    _access_token = access_token;
}

- (NSString *)refresh_token {
    if (!_refresh_token) {
        _refresh_token = [[NSString alloc] init];
    }
    return _refresh_token;
}

- (void)setRefresh_token:(NSString *)refresh_token {
    _refresh_token = refresh_token;
}

- (NSString *)expire_time {
    if (!_expire_time) {
        _expire_time = [[NSString alloc] init];
    }
    return _expire_time;
}

- (void)setExpire_time:(NSString *)expire_time {
    _expire_time = expire_time;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    UIImage *selectedImage = [UIImage imageNamed:@"Main_32"];
    UIImage *unselectedImage = [UIImage imageNamed:@"Main_32"];
    UITabBarItem * item = [self.tabBar.items objectAtIndex:0];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"Menu_32"];
    unselectedImage = [UIImage imageNamed:@"Menu_32"];
    item = [self.tabBar.items objectAtIndex:1];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"Camera_32"];
    unselectedImage = [UIImage imageNamed:@"Camera_32"];
    item = [self.tabBar.items objectAtIndex:2];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    selectedImage = [UIImage imageNamed:@"User_32"];
    unselectedImage = [UIImage imageNamed:@"User_32"];
    item = [self.tabBar.items objectAtIndex:3];
    [item setImage:unselectedImage];
    [item setSelectedImage:selectedImage];

    self.school_id = @"0";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVerifySchoolNotification:) name:@"VerifySchoolSuccessful" object:nil];
}

- (void) handleVerifySchoolNotification: (NSNotification*) aNotification {
    [self getSchool];
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [self.letters characterAtIndex: arc4random_uniform((unsigned int)[self.letters length])]];
    }
    return randomString;
}

- (NSMutableURLRequest *)createURLRequestWithURL:(NSString *)URL andPostData:(NSMutableDictionary *)postDictionary {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]init];
    NSMutableData *postData = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSMutableString * wa = [[NSMutableString alloc] init];
    //convert post distionary into a string
    if (postDictionary) {
        for (NSString *key in postDictionary) {
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [wa appendFormat:@"\r\n--%@\r\n", boundary];
            id postValue = [postDictionary valueForKey:key];
            if ([postValue isKindOfClass:[NSString class]]) {
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name= \"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[postValue dataUsingEncoding:NSUTF8StringEncoding]];
                [wa appendFormat:@"Content-Disposition: form-data; name= \"%@\"\r\n\r\n", key];
                [wa appendFormat:@"%@", postValue];
                //NSLog(@"!!!%@ %@", key, postValue);
            } else if ([postValue isKindOfClass:[UIImage class]]) {
                NSString *tmpStr = [self randomStringWithLength:18];
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpeg\"\r\n", key, tmpStr]  dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:UIImageJPEGRepresentation(postValue, 0.0)];

                [wa appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpeg\"\r\n", key, tmpStr];
                [wa appendFormat:@"Content-Type: image/jpeg\r\n"];
                [wa appendFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"];
                [wa appendString:@"!!!Image Data Here!!!"];
                //NSLog(@">.<%@ %@", key, postValue);
            } else {
                [NSException raise:@"Invalid Post Value" format:@"Received invalid post value while trying to create URL Request. Post values are required to be strings. The value for the following key was not a string: %@.", key];
            }
        }
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [wa appendFormat:@"\r\n--%@--\r\n", boundary];
    }

    //setup the request
    [urlRequest setURL:[NSURL URLWithString:URL]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];

    NSLog(@"Content-Type: multipart/form-data; boundary=%@",boundary);
    NSLog(@"%@", wa);

    return urlRequest;
}

- (void) getSchool {
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
    [itemDict setObject:self.access_token forKey:@"access_token"];
    [itemDict setObject:@"me" forKey:@"userid"];
    NSMutableURLRequest *request = [self createURLRequestWithURL:@"http://v2.api.boxbuy.cc/getUserData" andPostData:itemDict];
    NSError *requestError = [[NSError alloc] init];
    NSHTTPURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
    NSError *jsonError = nil;
    if (requestHandler != nil) {
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:requestHandler
                                  options:NSJSONReadingMutableContainers
                                  error:&jsonError];
        //NSLog(@"Response with json ==> %@", jsonData[@"Account"][@"schoolid"]);
        self.school_id = jsonData[@"Account"][@"schoolid"];
    }
}

@end
