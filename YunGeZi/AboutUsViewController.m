//
//  AboutUsViewController.m
//  YunGeZi
//
//  Created by Armour on 9/1/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AboutUsViewController.h"
#import "DeviceDetect.h"

@interface AboutUsViewController ()

@property (weak, nonatomic) IBOutlet UIView *aboutUsView;
@property (weak, nonatomic) IBOutlet UILabel *aboutUsLabel;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aboutUsView.layer.cornerRadius = 8.0f;
    self.aboutUsView.layer.borderWidth = 1.0f;
    self.aboutUsView.layer.borderColor = [UIColor  lightGrayColor].CGColor;
    self.aboutUsView.clipsToBounds = YES;
    if (IS_IPHONE_5) {
        self.aboutUsLabel.font = [UIFont systemFontOfSize:14];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
