//
//  BuyingViewController.m
//  YunGeZi
//
//  Created by Armour on 4/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "SellingViewController.h"
#import "MyTabBarController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "MobClick.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetPickerCustomPickerDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "SellingEnsureViewController.h"

@interface SellingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UIButton *numberButton;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *imageEncodedData_0;
@property (strong, nonatomic) NSString *imageEncodedData_1;
@property (strong, nonatomic) NSString *imageEncodedData_2;
@property (strong, nonatomic) NSString *imageEncodedData_3;
@property (strong, nonatomic) NSString *imageEncodedData_4;
@property (weak, nonatomic) IBOutlet UIButton *photoView_0;
@property (weak, nonatomic) IBOutlet UIButton *photoView_1;
@property (weak, nonatomic) IBOutlet UIButton *photoView_2;
@property (weak, nonatomic) IBOutlet UIButton *photoView_3;
@property (weak, nonatomic) IBOutlet UIButton *photoView_4;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton_0;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton_1;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton_2;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton_3;
@property (weak, nonatomic) IBOutlet UIButton *photoDeleteButton_4;
@property (strong, nonatomic) NSString *photoUpLoadID_0;
@property (strong, nonatomic) NSString *photoUpLoadID_1;
@property (strong, nonatomic) NSString *photoUpLoadID_2;
@property (strong, nonatomic) NSString *photoUpLoadID_3;
@property (strong, nonatomic) NSString *photoUpLoadID_4;
@property (nonatomic) NSUInteger photoNumber;
@property (nonatomic) NSUInteger photoWhichShouldDelete;
@property (strong, nonatomic) NSMutableDictionary *dict;
@property (weak, nonatomic) NSString *letters;

- (NSString *)randomStringWithLength:(int)len;

@end

@implementation SellingViewController

- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [self.letters characterAtIndex: arc4random_uniform((unsigned int)[self.letters length])]];
    }
    return randomString;
}

- (void)takePhoto {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera | UIImagePickerControllerSourceTypePhotoLibrary;
        NSLog(@"!!!!both");
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片获取失败" message:@"没有可用的照片来源" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
     }
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
        image = info[UIImagePickerControllerOriginalImage];
    switch (self.photoNumber) {
        case 0:
            [self.photoView_0 setBackgroundImage:image forState:UIControlStateDisabled];
            self.imageEncodedData_0 = [UIImageJPEGRepresentation([self.photoView_0 backgroundImageForState:UIControlStateDisabled], 0.0) base64EncodedStringWithOptions:0];
            break;
        case 1:
            [self.photoView_1 setBackgroundImage:image forState:UIControlStateDisabled];
            self.imageEncodedData_1 = [UIImageJPEGRepresentation([self.photoView_1 backgroundImageForState:UIControlStateDisabled], 0.0) base64EncodedStringWithOptions:0];
            break;
        case 2:
            [self.photoView_2 setBackgroundImage:image forState:UIControlStateDisabled];
            self.imageEncodedData_2 = [UIImageJPEGRepresentation([self.photoView_2 backgroundImageForState:UIControlStateDisabled], 0.0) base64EncodedStringWithOptions:0];
            break;
        case 3:
            [self.photoView_3 setBackgroundImage:image forState:UIControlStateDisabled];
            self.imageEncodedData_3 = [UIImageJPEGRepresentation([self.photoView_3 backgroundImageForState:UIControlStateDisabled], 0.0) base64EncodedStringWithOptions:0];
            break;
        case 4:
            [self.photoView_4 setBackgroundImage:image forState:UIControlStateDisabled];
            self.imageEncodedData_4 = [UIImageJPEGRepresentation([self.photoView_4 backgroundImageForState:UIControlStateDisabled], 0.0) base64EncodedStringWithOptions:0];
            break;
        default:
            break;
    }
    self.photoNumber++;
    [self refreshPhotoIcon];
    [self refreshDeleteIcon];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
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

- (NSString *)getImageID:(NSString *)encodedData {
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    NSString *tmpRandom = [self randomStringWithLength:18];
    [imageDict setObject:tab.access_token forKey:@"access_token"];
    [imageDict setObject:tmpRandom forKey:@"fileElementName"];
    [imageDict setObject:encodedData forKey:tmpRandom];
    NSMutableURLRequest *request = [self createURLRequestWithURL:@"http://img.boxbuy.cc/images/add" andPostData:imageDict];
    //建立连接，设置代理
    NSError *requestError = [[NSError alloc] init];
    NSHTTPURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
    //NSLog(@"Response code: %ld", (long)[requestResponse statusCode]);
    NSError *jsonError = nil;
    if (requestHandler != nil) {
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:requestHandler
                                  options:NSJSONReadingMutableContainers
                                  error:&jsonError];
        NSLog(@"Response with json ==> %@", jsonData);
        return jsonData[@"imageid"];
    }
    return @"";
}

- (void)uploadPhoto {
    if (self.photoNumber >= 1)
        self.photoUpLoadID_0 = [self getImageID:self.imageEncodedData_0];
    if (self.photoNumber >= 2)
        self.photoUpLoadID_1 = [self getImageID:self.imageEncodedData_1];
    if (self.photoNumber >= 3)
        self.photoUpLoadID_2 = [self getImageID:self.imageEncodedData_2];
    if (self.photoNumber >= 4)
        self.photoUpLoadID_3 = [self getImageID:self.imageEncodedData_3];
    if (self.photoNumber >= 5)
        self.photoUpLoadID_4 = [self getImageID:self.imageEncodedData_4];
}

- (NSString *)imageJsonArray {
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"["];
    if (self.photoNumber >= 1 && ![self.photoUpLoadID_0  isEqual: @""])
        [tmp appendString:[[NSString alloc] initWithFormat:@"%@", self.photoUpLoadID_0]];
    if (self.photoNumber >= 2 && ![self.photoUpLoadID_1  isEqual: @""])
        [tmp appendString:[[NSString alloc] initWithFormat:@",%@", self.photoUpLoadID_1]];
    if (self.photoNumber >= 3 && ![self.photoUpLoadID_2  isEqual: @""])
        [tmp appendString:[[NSString alloc] initWithFormat:@",%@", self.photoUpLoadID_2]];
    if (self.photoNumber >= 4 && ![self.photoUpLoadID_3  isEqual: @""])
        [tmp appendString:[[NSString alloc] initWithFormat:@",%@", self.photoUpLoadID_3]];
    if (self.photoNumber >= 5 && ![self.photoUpLoadID_4  isEqual: @""])
        [tmp appendString:[[NSString alloc] initWithFormat:@",%@", self.photoUpLoadID_4]];
    [tmp appendString:@"]"];
    NSLog(@"%@", tmp);
    return tmp;
}

- (NSString *)handlePrice:(NSString *)originalPrice {
    float tmp = [originalPrice floatValue];
    tmp *= 100;
    return [[NSString alloc] initWithFormat:@"%f", tmp];
}

- (void)uploadItem {
    dispatch_queue_t requestQueue = dispatch_queue_create("webRequestInUploadItem", NULL);
    dispatch_async(requestQueue, ^{
        @try {
            MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
            NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
            [itemDict setObject:tab.access_token forKey:@"access_token"];
            [itemDict setObject:self.objectName forKey:@"title"];
            [itemDict setObject:[self handlePrice: self.objectPrice] forKey:@"price"];
            [itemDict setObject:self.objectNumber forKey:@"amount"];
            [itemDict setObject:self.dict[self.objectQuality] forKey:@"degree"];
            [itemDict setObject:self.objectContent forKey:@"content"];
            [itemDict setObject:self.dict[self.objectLocation] forKey:@"location"];
            [itemDict setObject:self.dict[self.objectCategory] forKey:@"classid"];
            [itemDict setObject:@"1" forKey:@"payment"];
            [itemDict setObject:@"1" forKey:@"transport"];
            [itemDict setObject:self.photoUpLoadID_0 forKey:@"cover"];
            [itemDict setObject:[self imageJsonArray] forKey:@"images"];
            NSMutableURLRequest *request = [self createURLRequestWithURL:@"http://v2.api.boxbuy.cc/addItem" andPostData:itemDict];
            NSError *requestError = [[NSError alloc] init];
            NSHTTPURLResponse *requestResponse;
            NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&requestError];
            NSError *jsonError = nil;
            NSLog(@"%@", requestResponse);
            //if (requestHandler != nil) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:requestHandler
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
            NSLog(@"Response with json ==> %@", jsonData);
            //}
        }
        @catch (NSException *exception) {
            //NSLog(@"Exception: %@", exception);
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:TRUE];
            [self popAlert:@"上传失败" withMessage:@"您好像网络不太好哦╮(╯_╰)╭"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:TRUE];
            [self initObjectAttribute];
            [self popAlert:@"上传成功" withMessage:@"快去看看您的商品吧!（记得下拉刷新哦~）"];
        });
    });
}

- (IBAction)backGroundTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)initTxetViewWithPlaceholder {
    self.objectNameTextView.delegate = self;
    self.objectContentTextView.delegate = self;
    self.objectNameTextView.text = @"给宝贝起个名字吧~";
    self.objectContentTextView.text = @"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！";
    self.objectNameTextView.textColor = [UIColor lightGrayColor];
    self.objectContentTextView.textColor = [UIColor lightGrayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (IBAction)takePhotoButtonTouchUpInside:(UIButton *)sender {
    if (self.photoNumber == 5) {
        [self popAlert:@"图片数量超限" withMessage:@"哇您好像已经为您的宝贝照了很多照片啦~"];
    } else
        [self takePhoto];
}

- (void)prepareTextField {
    self.priceTextField.delegate = self;
}

- (void)setSchoolID {
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    [tab getSchool];
    self.school = tab.school_id;
}

- (void)initObjectAttribute {
    self.letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";       // used to generate random name of image
    self.school = @"0";
    self.photoNumber = 0;
    self.photoWhichShouldDelete = 0;
    self.photoDeleteButton_1.hidden = true;
    self.photoDeleteButton_2.hidden = true;
    self.photoDeleteButton_3.hidden = true;
    self.photoDeleteButton_4.hidden = true;
    self.objectCategory = @"请选择";
    self.objectLocation = @"请选择";
    self.objectNumber = @"请选择";
    self.objectPrice = @"";
    self.objectQuality = @"请选择";
    self.objectNameTextView.text = @"给宝贝起个名字吧~";
    self.objectNameTextView.textColor = [UIColor lightGrayColor];
    self.objectContentTextView.text = @"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！";
    self.objectContentTextView.textColor = [UIColor lightGrayColor];
    [self.photoView_0 setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self.photoView_1 setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self.photoView_2 setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self.photoView_3 setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self.photoView_4 setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self.categoryButton setTitle:@"    分类：请选择" forState:UIControlStateNormal];
    [self.locationButton setTitle:@"    地点：请选择" forState:UIControlStateNormal];
    [self.qualityButton setTitle:@"    成色：请选择" forState:UIControlStateNormal];
    [self.numberButton setTitle:@"    数量：请选择" forState:UIControlStateNormal];
    [self.priceTextField setText:@""];
    [self setSchoolID];
    [self refreshPhotoIcon];
    [self refreshDeleteIcon];
}

- (void)initDict {
    self.dict = [[NSMutableDictionary alloc] init];
    // 成色程度
    [self.dict setValue:@"100" forKey:@"全新"];
    [self.dict setValue:@"95" forKey:@"九五新"];
    [self.dict setValue:@"90" forKey:@"九成新"];
    [self.dict setValue:@"85" forKey:@"八五新"];
    [self.dict setValue:@"80" forKey:@"八成新"];
    [self.dict setValue:@"75" forKey:@"七五新"];
    [self.dict setValue:@"70" forKey:@"七成新"];
    [self.dict setValue:@"65" forKey:@"六五新"];
    [self.dict setValue:@"60" forKey:@"六成新"];
    [self.dict setValue:@"55" forKey:@"五五新"];
    [self.dict setValue:@"50" forKey:@"五成新"];
    // 浙江大学  1
    [self.dict setValue:@"1" forKey:@"紫金港"];
    [self.dict setValue:@"2" forKey:@"玉泉"];
    [self.dict setValue:@"3" forKey:@"西溪"];
    [self.dict setValue:@"4" forKey:@"华家池"];
    [self.dict setValue:@"5" forKey:@"之江"];
    // 杭州电子科技大学  2
    [self.dict setValue:@"1" forKey:@"下沙主校区"];
    [self.dict setValue:@"2" forKey:@"下沙东校区"];
    [self.dict setValue:@"3" forKey:@"文一校区"];
    [self.dict setValue:@"4" forKey:@"东岳校区"];
    // 杭州师范大学  3
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    [self.dict setValue:@"2" forKey:@"钱江校区"];
    [self.dict setValue:@"3" forKey:@"大塔儿巷校区"];
    [self.dict setValue:@"4" forKey:@"玉皇山校区"];
    // 浙江财经大学  5
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    // 浙江传播学院  6
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    [self.dict setValue:@"2" forKey:@"桐乡校区"];
    // 浙江大学城市学院  7
    [self.dict setValue:@"1" forKey:@"主校区"];
    // 浙江工商大学  8
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    [self.dict setValue:@"2" forKey:@"教工路校区"];
    // 浙江工业大学  9
    [self.dict setValue:@"1" forKey:@"屏峰校区"];
    [self.dict setValue:@"2" forKey:@"朝晖校区"];
    // 浙江经贸职业技术学院  12
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    // 浙江科技学院  13
    [self.dict setValue:@"1" forKey:@"小和山校区"];
    // 浙江理工大学  14
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    [self.dict setValue:@"2" forKey:@"文一校区"];
    [self.dict setValue:@"3" forKey:@"益乐校区"];
    [self.dict setValue:@"4" forKey:@"西城校区"];
    [self.dict setValue:@"5" forKey:@"北景园校区"];
    // 浙江树人大学  15
    [self.dict setValue:@"1" forKey:@"主校区"];
    // 中国计量学院  17
    [self.dict setValue:@"1" forKey:@"下沙校区"];
    // 中国美术学院  18
    [self.dict setValue:@"1" forKey:@"南山校区"];
    [self.dict setValue:@"2" forKey:@"象山校区"];
    // 分类：电子
    [self.dict setValue:@"2801" forKey:@"电子(电脑)"];
    [self.dict setValue:@"2802" forKey:@"电子(相机)"];
    [self.dict setValue:@"2803" forKey:@"电子(手机)"];
    [self.dict setValue:@"2804" forKey:@"电子(移动存储)"];
    [self.dict setValue:@"2805" forKey:@"电子(游戏机)"];
    [self.dict setValue:@"2806" forKey:@"电子(手环)"];
    [self.dict setValue:@"2807" forKey:@"电子(配件)"];
    [self.dict setValue:@"2808" forKey:@"电子(平板)"];
    // 分类：箱包
    [self.dict setValue:@"2001" forKey:@"箱包(拉杆箱)"];
    [self.dict setValue:@"2002" forKey:@"箱包(双肩包)"];
    [self.dict setValue:@"2003" forKey:@"箱包(单肩包)"];
    [self.dict setValue:@"2004" forKey:@"箱包(箱包配件)"];
    [self.dict setValue:@"2005" forKey:@"箱包(托运箱)"];
    [self.dict setValue:@"2006" forKey:@"箱包(钱包)"];
    [self.dict setValue:@"2007" forKey:@"箱包(情侣包)"];
    // 分类：鞋子
    [self.dict setValue:@"2101" forKey:@"鞋子(休闲鞋)"];
    [self.dict setValue:@"2102" forKey:@"鞋子(高跟鞋)"];
    [self.dict setValue:@"2103" forKey:@"鞋子(情侣鞋)"];
    [self.dict setValue:@"2104" forKey:@"鞋子(正装鞋)"];
    [self.dict setValue:@"2105" forKey:@"鞋子(帆布鞋)"];
    [self.dict setValue:@"2106" forKey:@"鞋子(板鞋)"];
    [self.dict setValue:@"2107" forKey:@"鞋子(拖鞋)"];
    [self.dict setValue:@"2108" forKey:@"鞋子(凉鞋)"];
    [self.dict setValue:@"2109" forKey:@"鞋子(棉鞋)"];
    [self.dict setValue:@"2110" forKey:@"鞋子(靴子)"];
    // 分类：衣服
    [self.dict setValue:@"2201" forKey:@"衣服(T恤)"];
    [self.dict setValue:@"2202" forKey:@"衣服(卫衣)"];
    [self.dict setValue:@"2203" forKey:@"衣服(夹克)"];
    [self.dict setValue:@"2204" forKey:@"衣服(棉衣)"];
    [self.dict setValue:@"2205" forKey:@"衣服(衬衫)"];
    [self.dict setValue:@"2206" forKey:@"衣服(针织衫)"];
    [self.dict setValue:@"2207" forKey:@"衣服(毛衣)"];
    [self.dict setValue:@"2208" forKey:@"衣服(羽绒服)"];
    [self.dict setValue:@"2209" forKey:@"衣服(情侣装)"];
    [self.dict setValue:@"2210" forKey:@"衣服(正装)"];
    [self.dict setValue:@"2211" forKey:@"衣服(运动装)"];
    // 分类：家居
    [self.dict setValue:@"2301" forKey:@"家居(餐具)"];
    [self.dict setValue:@"2302" forKey:@"家居(装修用品)"];
    [self.dict setValue:@"2303" forKey:@"家居(床上用品)"];
    [self.dict setValue:@"2304" forKey:@"家居(办公用品)"];
    [self.dict setValue:@"2305" forKey:@"家居(装饰摆件)"];
    [self.dict setValue:@"2306" forKey:@"家居(挂饰/壁饰)"];
    [self.dict setValue:@"2307" forKey:@"家居(收纳)"];
    [self.dict setValue:@"2308" forKey:@"家居(电器)"];
    [self.dict setValue:@"2309" forKey:@"家居(清洁用品)"];
    [self.dict setValue:@"2310" forKey:@"家居(浴室用品)"];
    // 分类：学习
    [self.dict setValue:@"2401" forKey:@"学习(教材/教辅)"];
    [self.dict setValue:@"2402" forKey:@"学习(历年考题)"];
    [self.dict setValue:@"2403" forKey:@"学习(学霸笔记)"];
    [self.dict setValue:@"2404" forKey:@"学习(考试专用)"];
    [self.dict setValue:@"2405" forKey:@"学习(课外书籍)"];
    [self.dict setValue:@"2406" forKey:@"学习(考试用具)"];
    // 分类：运动
    [self.dict setValue:@"2501" forKey:@"运动(球拍)"];
    [self.dict setValue:@"2502" forKey:@"运动(球)"];
    [self.dict setValue:@"2503" forKey:@"运动(配件)"];
    [self.dict setValue:@"2504" forKey:@"运动(健身器材)"];
    // 分类：玩乐
    [self.dict setValue:@"2601" forKey:@"玩乐(桌游牌)"];
    [self.dict setValue:@"2602" forKey:@"玩乐(游戏机)"];
    [self.dict setValue:@"2603" forKey:@"玩乐(玩具)"];
    [self.dict setValue:@"2604" forKey:@"玩乐(玩偶)"];
    [self.dict setValue:@"2605" forKey:@"玩乐(装饰品)"];
    [self.dict setValue:@"2606" forKey:@"玩乐(乐器)"];
    [self.dict setValue:@"2607" forKey:@"玩乐(游戏配件)"];
    [self.dict setValue:@"2608" forKey:@"玩乐(乐器配件)"];
    // 分类：食饮
    [self.dict setValue:@"2701" forKey:@"食饮(坚果/蜜饯)"];
    [self.dict setValue:@"2702" forKey:@"食饮(糖果/巧克力)"];
    [self.dict setValue:@"2703" forKey:@"食饮(糕点)"];
    [self.dict setValue:@"2704" forKey:@"食饮(方便速食)"];
    [self.dict setValue:@"2705" forKey:@"食饮(营养品)"];
    [self.dict setValue:@"2706" forKey:@"食饮(饮料)"];
    [self.dict setValue:@"2707" forKey:@"食饮(药剂)"];
    [self.dict setValue:@"2708" forKey:@"食饮(特产)"];
    [self.dict setValue:@"2709" forKey:@"食饮(保健品)"];
    [self.dict setValue:@"2710" forKey:@"食饮(酒品)"];
    [self.dict setValue:@"2711" forKey:@"食饮(其他)"];
    // 分类：美护
    [self.dict setValue:@"2901" forKey:@"美护(化妆品)"];
    [self.dict setValue:@"2902" forKey:@"美护(保暖品)"];
    [self.dict setValue:@"2903" forKey:@"美护(保健品)"];
    [self.dict setValue:@"2904" forKey:@"美护(洗浴用品)"];
    [self.dict setValue:@"2905" forKey:@"美护(美发用品)"];
    [self.dict setValue:@"2906" forKey:@"美护(饰品)"];
    // 分类：非实物
    [self.dict setValue:@"3001" forKey:@"非实物(租赁)"];
    [self.dict setValue:@"3002" forKey:@"非实物(劳力)"];
    [self.dict setValue:@"3003" forKey:@"非实物(账号)"];
    [self.dict setValue:@"3004" forKey:@"非实物(其他)"];
    // 分类：交通工具
    [self.dict setValue:@"3101" forKey:@"交通工具(滑板轮滑)"];
    [self.dict setValue:@"3102" forKey:@"交通工具(自行车)"];
    [self.dict setValue:@"3103" forKey:@"交通工具(电动车)"];
    [self.dict setValue:@"3104" forKey:@"交通工具(汽车)"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDict];
    [self initObjectAttribute];
    [self initTxetViewWithPlaceholder];
    [self prepareTextField];
    [self addIndicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCategorySelection:) name:@"CategorySelectFinished" object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //设置动画的名字
    [UIView beginAnimations:@"TextFieldKeyboardAppear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.3];
    //使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    if (textField.tag == 7) {
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 200, self.view.frame.size.width, self.view.frame.size.height);
    }
    //设置动画结束
    [UIView commitAnimations];
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //设置动画的名字
    [UIView beginAnimations:@"TextFieldKeyboardDisappear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.15];
    //使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    if (textField.tag == 7) {
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 200, self.view.frame.size.width, self.view.frame.size.height);
    }
    //设置动画结束
    [textField resignFirstResponder];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 7) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //设置动画的名字
    [UIView beginAnimations:@"TextViewKeyboardAppear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.3];
    //使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    if (textView.tag == 5) {
        if ([textView.text isEqualToString:@"给宝贝起个名字吧~"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    } else if (textView.tag == 6) {
        if ([textView.text isEqualToString:@"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 100, self.view.frame.size.width, self.view.frame.size.height);
    }
    //设置动画结束
    [UIView commitAnimations];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //设置动画的名字
    [UIView beginAnimations:@"TextViewKeyboardDisappear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.15];
    //使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    if (textView.tag == 5) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"给宝贝起个名字吧~";
            textView.textColor = [UIColor lightGrayColor];
        }
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.objectName = textView.text;
    } else if (textView.tag == 6) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！";
            textView.textColor = [UIColor lightGrayColor];
        }
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height);
        self.objectContent = textView.text;
    }
    [textView resignFirstResponder];
    //设置动画结束
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.tag == 5) {
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

- (void) handleCategorySelection: (NSNotification*) aNotification {
    NSDictionary *dict = [[NSDictionary alloc] init];
    dict = [aNotification userInfo];
    NSString *tmp = [[NSString alloc] initWithFormat:@"%@(%@)", dict[@"0"], dict[@"1"]];
    self.objectCategory = tmp;
    [self.categoryButton setTitle:[NSString stringWithFormat:@"    类别：%@", tmp] forState:UIControlStateNormal];
}

- (IBAction)chooseCategoryButtonTouchUpInside:(UIButton *)sender {
    [self.view endEditing:YES];
    ActionSheetPickerCustomPickerDelegate *delg = [[ActionSheetPickerCustomPickerDelegate alloc] init];
    NSNumber *yass1 = @0;
    NSNumber *yass2 = @0;
    NSArray *initialSelections = @[yass1, yass2];
    [ActionSheetCustomPicker showPickerWithTitle:@"选择类别"
                                        delegate:delg
                                showCancelButton:YES
                                          origin:sender
                               initialSelections:initialSelections];
}

- (IBAction)chooseLocationButtonTouchUpInside:(UIButton *)sender {
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    self.school = tab.school_id;
    NSArray *option;
    // default  0
    if ([self.school isEqual: @"0"])
        option = [NSArray arrayWithObjects:@"请选择", nil];
    // 浙江大学  1
    if ([self.school isEqual: @"1"])
        option = [NSArray arrayWithObjects:@"请选择", @"紫金港", @"玉泉", @"西溪", @"华家池", @"之江", nil];
    // 杭州电子科技大学  2
    if ([self.school isEqual: @"2"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙主校区", @"下沙东校区", @"文一校区", @"东岳校区", nil];
    // 杭州师范大学  3
    if ([self.school isEqual: @"3"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", @"钱江校区", @"大塔儿巷校区", @"玉皇山校区", nil];
    // 浙江财经大学  5
    if ([self.school isEqual: @"5"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", nil];
    // 浙江传播学院  6
    if ([self.school isEqual: @"6"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", @"桐乡校区", nil];
    // 浙江大学城市学院  7
    if ([self.school isEqual: @"7"])
        option = [NSArray arrayWithObjects:@"请选择", @"主校区", nil];
    // 浙江工商大学  8
    if ([self.school isEqual: @"8"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", @"教工路校区", nil];
    // 浙江工业大学  9
    if ([self.school isEqual: @"9"])
        option = [NSArray arrayWithObjects:@"请选择", @"屏峰校区", @"朝晖校区", nil];
    // 浙江经贸职业技术学院  12
    if ([self.school isEqual: @"12"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", nil];
    // 浙江科技学院  13
    if ([self.school isEqual: @"12"])
        option = [NSArray arrayWithObjects:@"请选择", @"小和山校区", nil];
    // 浙江理工大学  14
    if ([self.school isEqual: @"14"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", @"文一校区", @"益乐校区", @"西城校区", @"北景园校区", nil];
    // 浙江树人大学  15
    if ([self.school isEqual: @"15"])
        option = [NSArray arrayWithObjects:@"请选择", @"主校区", nil];
    // 中国计量学院  17
    if ([self.school isEqual: @"17"])
        option = [NSArray arrayWithObjects:@"请选择", @"下沙校区", nil];
    // 中国美术学院  18
    if ([self.school isEqual: @"18"])
        option = [NSArray arrayWithObjects:@"请选择", @"南山校区", @"象山校区", nil];

    [ActionSheetStringPicker showPickerWithTitle:@"选择校区"
                                            rows:option
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self.locationButton setTitle:[NSString stringWithFormat:@"    校区：%@", selectedValue] forState:UIControlStateNormal];
                                           self.objectLocation = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)chooseQualityButtonTouchUpInside:(UIButton *)sender {
    NSArray *option = [NSArray arrayWithObjects:@"请选择", @"全新", @"九五新", @"九成新", @"八五新", @"八成新", @"七五新", @"七成新", @"六五新", @"六成新", @"五五新", @"五成新", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"选择成色"
                                            rows:option
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self.qualityButton setTitle:[NSString stringWithFormat:@"    成色：%@", selectedValue] forState:UIControlStateNormal];
                                           self.objectQuality = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)choosePriceButtonTouchUpInside:(UIButton *)sender {
    [self.priceTextField becomeFirstResponder];
}

- (IBAction)chooseNumberButtonTouchUpInside:(UIButton *)sender {
    NSArray *option = [NSArray arrayWithObjects:@"请选择", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",
                                                @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20",
                                                @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30",
                                                @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40",
                                                @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50",
                                                @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60",
                                                @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70",
                                                @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80",
                                                @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"90",
                                                @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"选择数量"
                                            rows:option
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self.numberButton setTitle:[NSString stringWithFormat:@"    数量：%@", selectedValue] forState:UIControlStateNormal];
                                           self.objectNumber = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (BOOL)checkPrice {
    NSString *price = [[NSString alloc] init];
    NSArray *digit = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"."];
    int dot = 0;
    BOOL flag = true;
    price = self.priceTextField.text;
    for (int i = 0; i < price.length; i++) {
        NSString *ch = [price substringWithRange:NSMakeRange(i, 1)];
        if (![digit containsObject:ch]) {
            flag = false;
        } else if ([ch isEqual:@"."]) {
            if (++dot > 1)
                flag = false;
            if (i == 0 || i != price.length - 2)
                flag = false;
        }
    }
    //NSLog(@"%d %d",flag, dot);
    if (!flag) {
        [self popAlert:@"信息不完整" withMessage:@"哇您的价格好像填错啦。。\n (最多精确到小数点后一位哦)"];
    }
    return flag;
}

- (IBAction)publishButtonTouchUpInside:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (![self checkPrice])
        return;

    self.objectPrice = self.priceTextField.text;
    self.objectName = self.objectNameTextView.text;
    self.objectContent = self.objectContentTextView.text;

    if ([self.objectName isEqual:@""] || [self.objectName isEqual:@"给宝贝起个名字吧~"]) {
        [self popAlert:@"信息不完整" withMessage:@"给您的宝贝取个名字吧~"];
    } else if ([self.objectContent isEqual:@""] || [self.objectContent isEqual:@"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！"]) {
        [self popAlert:@"信息不完整" withMessage:@"跟大家讲讲您的宝贝的故事吧~"];
    } else if ([self.objectCategory isEqual: @"请选择"] || [self.dict valueForKey:self.objectCategory]== nil) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选分类 >_<"];
    } else if ([self.objectLocation isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选校区 >_<"];
    }  else if ([self.objectQuality isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选成色 >_<"];
    }else if ([self.objectPrice isEqual: @""]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没填价格 >_<"];
    } else if ([self.objectNumber isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选数量 >_<"];
    } else if (self.photoNumber == 0) {
        [self popAlert:@"未上传图片" withMessage:@"为您的宝贝拍几张照片吧~"];
    } else {
        [self publish];
    }
}

- (void)publish {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [self uploadPhoto];
    [self uploadItem];
}

- (void)refreshDeleteIcon {
    self.photoDeleteButton_0.hidden = true;
    self.photoDeleteButton_1.hidden = true;
    self.photoDeleteButton_2.hidden = true;
    self.photoDeleteButton_3.hidden = true;
    self.photoDeleteButton_4.hidden = true;
    switch (self.photoNumber) {
        case 5:
            self.photoDeleteButton_4.hidden = false;
        case 4:
            self.photoDeleteButton_3.hidden = false;
        case 3:
            self.photoDeleteButton_2.hidden = false;
        case 2:
            self.photoDeleteButton_1.hidden = false;
        case 1:
            self.photoDeleteButton_0.hidden = false;
        default:
            break;
    }
}

- (void)refreshPhotoIcon {
    self.photoView_0.hidden = true;
    self.photoView_1.hidden = true;
    self.photoView_2.hidden = true;
    self.photoView_3.hidden = true;
    self.photoView_4.hidden = true;
    self.photoView_0.enabled = true;
    self.photoView_1.enabled = true;
    self.photoView_2.enabled = true;
    self.photoView_3.enabled = true;
    self.photoView_4.enabled = true;
    switch (self.photoNumber) {
        case 5:
            self.photoView_4.enabled = false;
        case 4:
            self.photoView_4.hidden = false;
            self.photoView_3.enabled = false;
        case 3:
            self.photoView_3.hidden = false;
            self.photoView_2.enabled = false;
        case 2:
            self.photoView_2.hidden = false;
            self.photoView_1.enabled = false;
        case 1:
            self.photoView_1.hidden = false;
            self.photoView_0.enabled = false;
        case 0:
            self.photoView_0.hidden = false;
        default:
            break;
    }
}

- (IBAction)photoDeleteButtonOneTouchUpInside:(UIButton *)sender {
    if (self.photoNumber >= 1) {
        self.photoWhichShouldDelete = 1;
        [self popDeleteAlert:@"删除照片" withMessage:@"您确定要删除这张照片吗？"];
    } else
        return;
}

- (IBAction)photoDeleteButtonTwoTouchUpInside:(UIButton *)sender {
    if (self.photoNumber >= 2) {
        self.photoWhichShouldDelete = 2;
        [self popDeleteAlert:@"删除照片" withMessage:@"您确定要删除这张照片吗？"];
    } else
        return;
}

- (IBAction)photoDeleteButtonThreeTouchUpInside:(UIButton *)sender {
    if (self.photoNumber >= 3) {
        self.photoWhichShouldDelete = 3;
        [self popDeleteAlert:@"删除照片" withMessage:@"您确定要删除这张照片吗？"];
    } else
        return;
}

- (IBAction)photoDeleteButtonFourTouchUpInside:(UIButton *)sender {
    if (self.photoNumber >= 4) {
        self.photoWhichShouldDelete = 4;
        [self popDeleteAlert:@"删除照片" withMessage:@"您确定要删除这张照片吗？"];
    } else
        return;
}

- (IBAction)photoDeleteButtonFiveTouchUpInside:(UIButton *)sender {
    if (self.photoNumber >= 5) {
        self.photoWhichShouldDelete = 5;
        [self popDeleteAlert:@"删除照片" withMessage:@"您确定要删除这张照片吗？"];
    } else
        return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我要卖"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我要卖"];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        switch (self.photoWhichShouldDelete) {
            case 1:
                if (self.photoNumber == 1) {
                    self.imageEncodedData_0 = nil;
                }
                if (self.photoNumber == 2) {
                    [self.photoView_0 setBackgroundImage:[self.photoView_1 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_0 = self.imageEncodedData_1;
                    self.imageEncodedData_1 = nil;
                }
                if (self.photoNumber == 3) {
                    [self.photoView_0 setBackgroundImage:[self.photoView_1 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_0 = self.imageEncodedData_1;
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = nil;
                }
                if (self.photoNumber == 4) {
                    [self.photoView_0 setBackgroundImage:[self.photoView_1 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_0 = self.imageEncodedData_1;
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = nil;
                }
                if (self.photoNumber == 5) {
                    [self.photoView_0 setBackgroundImage:[self.photoView_1 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_3 setBackgroundImage:[self.photoView_4 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_0 = self.imageEncodedData_1;
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = self.imageEncodedData_4;
                    self.imageEncodedData_4 = nil;
                }
                break;

            case 2:
                if (self.photoNumber == 2) {
                    self.imageEncodedData_1 = nil;
                }
                if (self.photoNumber == 3) {
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = nil;
                }
                if (self.photoNumber == 4) {
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = nil;
                }
                if (self.photoNumber == 5) {
                    [self.photoView_1 setBackgroundImage:[self.photoView_2 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_3 setBackgroundImage:[self.photoView_4 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_1 = self.imageEncodedData_2;
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = self.imageEncodedData_4;
                    self.imageEncodedData_4 = nil;
                }
                break;

            case 3:
                if (self.photoNumber == 3) {
                    self.imageEncodedData_2 = nil;
                }
                if (self.photoNumber == 4) {
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = nil;
                }
                if (self.photoNumber == 5) {
                    [self.photoView_2 setBackgroundImage:[self.photoView_3 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    [self.photoView_3 setBackgroundImage:[self.photoView_4 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_2 = self.imageEncodedData_3;
                    self.imageEncodedData_3 = self.imageEncodedData_4;
                    self.imageEncodedData_4 = nil;
                }
                break;

            case 4:
                if (self.photoNumber == 4) {
                    self.imageEncodedData_3 = nil;
                }
                if (self.photoNumber == 5) {
                    [self.photoView_3 setBackgroundImage:[self.photoView_4 backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
                    self.imageEncodedData_3 = self.imageEncodedData_4;
                    self.imageEncodedData_4 = nil;
                }
                break;

            case 5:
                if (self.photoNumber == 5) {
                    self.imageEncodedData_4 = nil;
                }
                break;

            default:
                break;
        }
        self.photoWhichShouldDelete = 0;
        self.photoNumber--;
        [self refreshPhotoIcon];
        [self refreshDeleteIcon];
    }
}

- (void) popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void) popDeleteAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"是的"
                                          otherButtonTitles:@"取消", nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MyTabBarController * tab = (MyTabBarController *)self.tabBarController;
    if([segue.identifier isEqualToString:@"publish"]){
        SellingEnsureViewController *controller = (SellingEnsureViewController *)segue.destinationViewController;
        [controller setAccess_token:tab.access_token];
        [controller setObjectCategory:self.objectCategory];
        [controller setObjectContent:self.objectContent];
        [controller setObjectLocation:self.objectLocation];
        [controller setObjectName:self.objectName];
        [controller setObjectNumber:self.objectNumber];
        [controller setObjectPrice:self.objectPrice];
        [controller setObjectQuality:self.objectQuality];
        [controller setPhotoNumber:self.photoNumber];
        [controller setImage_id_1:self.photoUpLoadID_1];
        [controller setImage_id_2:self.photoUpLoadID_2];
        [controller setImage_id_3:self.photoUpLoadID_3];
        [controller setImage_id_4:self.photoUpLoadID_4];
    }
}

@end
