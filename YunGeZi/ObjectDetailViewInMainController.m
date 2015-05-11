//
//  ObjectDetailViewController.m
//  YunGeZi
//
//  Created by Armour on 5/7/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectDetailViewInMainController.h"
#import "WebViewJavascriptBridge.h"
#import "ObjectBuyInMainViewController.h"

@interface ObjectDetailInMainViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectDetailWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectDetailInMainViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectDetailWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"buy"]) {
            [self performSegueWithIdentifier:@"buyItemInMain" sender:self];
        } else if ([data isEqualToString:@"deleted"]) {
            [self popAlert:@"删除商品" withMessage:@"删除成功~\(≧▽≦)/~"];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        responseCallback(self.objectNumber);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/items/show.html?item_id=%@", self.objectNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectDetailWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"buyItemInMain"]) {
        ObjectBuyInMainViewController *controller = (ObjectBuyInMainViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
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
