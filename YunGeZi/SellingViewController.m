//
//  BuyingViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SellingViewController.h"
#import "MyTabBarController.h"
#import "WebViewJavascriptBridge.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MobClick.h"

@interface SellingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *SellingWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *photoActivityIndicator;
@property (strong, nonatomic) NSString *imageEncodedData;
@property WebViewJavascriptBridge* bridge;

- (NSString *)randomStringWithLength:(int)len;

@end

@implementation SellingViewController

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random_uniform((unsigned int)[letters length])]];
    }
    return randomString;
}

- (void)takePhoto {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    /*if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera | UIImagePickerControllerSourceTypePhotoLibrary;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片获取失败" message:@"没有可用的照片来源" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
     }*/
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
                NSString *tmpStr = [self randomStringWithLength:8];
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpeg\"\r\n", key, tmpStr]  dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:UIImageJPEGRepresentation(postValue, 0.8)];

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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
        image = info[UIImagePickerControllerOriginalImage];

    /*MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    [imageDict setObject:tab.access_token forKey:@"access_token"];
    [imageDict setObject:image forKey:@"image"];
    NSMutableURLRequest *request = [self createURLRequestWithURL:@"http://www.boxbuy.cc/images/add" andPostData:imageDict];
    //建立连接，设置代理
    NSError *requestError = [[NSError alloc] init];
    NSHTTPURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
    NSLog(@"Response code: %ld", (long)[requestResponse statusCode]);

    NSString *responseData = [[NSString alloc] initWithData:requestHandler encoding:NSUTF8StringEncoding];
    NSLog(@"Response data: %@", responseData);

    NSError *jsonError = nil;
    NSDictionary *jsonData = [NSJSONSerialization
                              JSONObjectWithData:requestHandler
                              options:NSJSONReadingMutableContainers
                              error:&jsonError];
    NSLog(@"Response with json ==> %@", jsonData);
     */

    [self dismissViewControllerAnimated:YES completion:NULL];

    dispatch_queue_t requestQueue = dispatch_queue_create("photoUpLoad", NULL);
    dispatch_async(requestQueue, ^{
        [self.photoActivityIndicator setHidden:NO];
        [self.photoActivityIndicator startAnimating];
        self.imageEncodedData = [UIImageJPEGRepresentation(image, 0.0) base64EncodedStringWithOptions:0];
        id data = self.imageEncodedData;
        [self.bridge callHandler:@"getImageData" data:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoActivityIndicator stopAnimating];
            [self.photoActivityIndicator setHidden:TRUE];
        });
    });

}

- (void)addIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];

    self.photoActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.photoActivityIndicator setCenter:self.view.center];
    [self.photoActivityIndicator setHidesWhenStopped:TRUE];
    [self.photoActivityIndicator setHidden:YES];
    [self.view addSubview:self.photoActivityIndicator];
    [self.view bringSubviewToFront:self.photoActivityIndicator];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

- (void)addWebViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_SellingWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"takePhoto"]) {
            self.imageEncodedData = NULL;
            [self takePhoto];
            responseCallback(@"0.0");
        }
    }];
}

- (void)loadWebViewRequest {
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/items/add.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_SellingWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebViewBridge];
    [self addIndicator];
    [self loadWebViewRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"SellingPage"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"SellingPage"];
}

@end
