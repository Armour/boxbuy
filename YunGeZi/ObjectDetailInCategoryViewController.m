//
//  ObjectDetailInCategoryViewController.m
//  YunGeZi
//
//  Created by Armour on 5/8/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectDetailInCategoryViewController.h"
#import "ObjectBuyInCategoryViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ObjectDetailInCategoryViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectDetailWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectDetailInCategoryViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectDetailWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"buy"]) {
            [self performSegueWithIdentifier:@"buyItemInCategory" sender:self];
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
    if([segue.identifier isEqualToString:@"buyItemInCategory"]) {
        ObjectBuyInCategoryViewController *controller = (ObjectBuyInCategoryViewController *)segue.destinationViewController;
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
