//
//  AccountDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AccountDetailViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "LoginInfo.h"

@interface AccountDetailTableViewController()
;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (strong, nonatomic) UIAlertController *actionSheet;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *loadingMask;
@property (weak, nonatomic) NSString *letters;

@end

@implementation AccountDetailTableViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"我的"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareItem];
    [self prepareActionSheet];
    [self prepareMyIndicator];
    [self prepareLoadingMask];
    [self prepareMyNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
}

#pragma mark - Inner Helper

- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [self.letters characterAtIndex: arc4random_uniform((unsigned int)[self.letters length])]];
    }
    return randomString;
}

#pragma mark - Prepare Item

- (void)prepareItem {
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height / 2;
    self.avatarImageView.clipsToBounds = YES;
    self.letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    [self refreshUserInfo];
}

- (void)refreshUserInfo {
    [self.avatarImageView sd_setImageWithURL:[[NSURL alloc] initWithString:[LoginInfo sharedInfo].photoUrlString]
                            placeholderImage:[UIImage imageNamed:@"default_headicon"]];
    [self.nickenameLabel setText:@"立即设置"];
    [self.introLabel setText:@"立即设置"];
}

#pragma mark - Notification

- (void)prepareMyNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUserInfo)
                                                 name:@"CachedUserInfoRefreshed"
                                               object:nil];
}

#pragma mark - Prepare Activity Indicator

- (void)prepareMyIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.activityIndicator setHidesWhenStopped:TRUE];
    [self.activityIndicator setHidden:YES];
    [self.view addSubview:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Mask When Loading

- (void)prepareLoadingMask {
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.loadingMask setBackgroundColor:[UIColor grayColor]];
    self.loadingMask.alpha = 0.4;
}

- (void)addLoadingMask {
    [self.view addSubview:self.loadingMask];
}

- (void)removeLoadingMask {
    [self.loadingMask removeFromSuperview];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        [self presentViewController:self.actionSheet animated:YES completion:nil];
    } else if (indexPath.item == 1) {
        [self performSegueWithIdentifier:@"showChangeNickname" sender:self];
    } else if (indexPath.item == 2) {
        [self performSegueWithIdentifier:@"showChangeUserIntro" sender:self];
    }
}

#pragma mark - Prepare Action Sheet

- (void)prepareActionSheet {
    self.actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                           message:nil
                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                                                             [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                                                         }];
    UIAlertAction *lookAction = [UIAlertAction actionWithTitle:@"查看大图"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self performSegueWithIdentifier:@"showUserAvatar2" sender:self];
                                                       }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"上传：使用相机"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self getAvatar:1];
                                                         }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"上传：本地相册"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self getAvatar:2];
                                                        }];
    [self.actionSheet addAction:lookAction];
    [self.actionSheet addAction:cameraAction];
    [self.actionSheet addAction:albumAction];
    [self.actionSheet addAction:cancelAction];
}

#pragma mark - Upload Avatar

- (void)getAvatar:(NSUInteger)mark {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    if (mark == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (mark == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照片获取失败"
                                                        message:@"没有可用的照片来源"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    imagePicker.allowsEditing = YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10)
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
        image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSString *encodedData = [UIImageJPEGRepresentation(image, 0.0) base64EncodedStringWithOptions:0];
    [self upLoadImageWithData:encodedData];
}

#pragma mark - Upload Avatar 

- (void)upLoadImageWithData:(NSString *)encodedData {
    [self addLoadingMask];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    NSString *tmpRandom = [self randomStringWithLength:18];
    [imageDict setObject:[LoginInfo sharedInfo].accessToken forKey:@"access_token"];
    [imageDict setObject:tmpRandom forKey:@"fileElementName"];
    [imageDict setObject:encodedData forKey:tmpRandom];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://img.boxbuy.cc/images/add"
       parameters:imageDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%@", responseObject);
              [manager POST:@"http://v2.api.uboxs.com/setAccountHeadicon"
                 parameters:@{@"access_token" : [LoginInfo sharedInfo].accessToken,
                              @"headiconid" : [responseObject valueForKeyPath:@"imageid"]}
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"%@", responseObject);
                        if ([[responseObject valueForKeyPath:@"uniError"] isEqual:@0]) {
                            [[LoginInfo sharedInfo] refreshSharedUserInfo];
                            [self popAlert:@"修改成功~" withMessage:@"耶！头像修改成功~😝"];
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self popAlert:@"上传失败" withMessage:[responseObject valueForKeyPath:@"msg"]];
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self popAlert:@"上传失败" withMessage:@"更新头像失败，请稍后重试~"];
                        [self removeLoadingMask];
                        [self.activityIndicator stopAnimating];
                    }];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self popAlert:@"上传失败" withMessage:@"上传图片失败，请稍后重试~"];
              [self removeLoadingMask];
              [self.activityIndicator stopAnimating];
          }];
}

#pragma mark - Alert

- (void)popAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView * alert =[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

@end
