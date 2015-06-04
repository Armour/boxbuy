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

@interface SellingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UIButton *numberButton;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *photoActivityIndicator;
@property (strong, nonatomic) NSString *imageEncodedData;

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
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera | UIImagePickerControllerSourceTypePhotoLibrary;
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
        //id data = self.imageEncodedData;
        //[self.bridge callHandler:@"getImageData" data:data];
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
    [self takePhoto];
}

- (void)prepareTextField {
    self.priceTextField.delegate = self;
}

- (void)initObjectAttribute {
    self.objectCategory = @"请选择";
    self.objectLocation = @"请选择";
    self.objectNumber = @"请选择";
    self.objectPrice = @"";
    self.objectQuality = @"请选择";
    self.objectNameTextView.text = @"给宝贝起个名字吧~";
    self.objectContentTextView.text = @"聊聊她的故事吧，附上你的手机号，会让交易更加快速哦！";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initObjectAttribute];
    [self initTxetViewWithPlaceholder];
    [self prepareTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCategorySelection:) name:@"CategorySelectFinished" object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //设置动画的名字
    [UIView beginAnimations:@"TextFieldKeyboardAppear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
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
    [UIView setAnimationDuration:0.20];
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
    [UIView setAnimationDuration:0.20];
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
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height);
    }
    //设置动画结束
    [UIView commitAnimations];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //设置动画的名字
    [UIView beginAnimations:@"TextViewKeyboardDisappear" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
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
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height);
        self.objectContent = textView.text;
    } else if (textView.tag == 7) {
        //设置视图移动的位移
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height);
        self.objectPrice = textView.text;
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
    NSArray *option = [NSArray arrayWithObjects:@"请选择", @"之江", @"玉泉", @"紫金港", @"西溪", @"华家池", nil];
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
    } else if ([self.objectCategory isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选分类 >_<"];
    } else if ([self.objectLocation isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选校区 >_<"];
    }  else if ([self.objectQuality isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选成色 >_<"];
    }else if ([self.objectPrice isEqual: @""]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没填价格 >_<"];
    } else if ([self.objectNumber isEqual: @"请选择"]) {
        [self popAlert:@"信息不完整" withMessage:@"您好像没选数量 >_<"];
    } else
        [self publish];
}

- (void)publish {
    NSLog(@"%@", self.objectName);
    NSLog(@"%@", self.objectContent);
    NSLog(@"%@", self.objectCategory);
    NSLog(@"%@", self.objectLocation);
    NSLog(@"%@", self.objectQuality);
    NSLog(@"%@", self.objectPrice);
    NSLog(@"%@", self.objectNumber);
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

- (void) popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
