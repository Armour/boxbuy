//
//  BuyingViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "BuyingViewController.h"
#import "MyTabBarController.h"
#import "WebViewJavascriptBridge.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface BuyingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *BuyingWebView;
@property (strong, nonatomic) NSString *imageData;
@property WebViewJavascriptBridge* bridge;

@end

@implementation BuyingViewController

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
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }*/
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imageData = [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:0];
    id data = self.imageData;
    NSLog(@"%@", data);
    [self.bridge callHandler:@"getImageData" data:data];
}

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_BuyingWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"takePhoto"]) {
            self.imageData = NULL;
            [self takePhoto];
            responseCallback(self.imageData);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/items/add.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_BuyingWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
