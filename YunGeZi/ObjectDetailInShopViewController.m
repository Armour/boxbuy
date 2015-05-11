//
//  ObjectDetailInShopViewController.m
//  YunGeZi
//
//  Created by Armour on 5/9/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ObjectDetailInShopViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ObjectDetailInShopViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *objectDetailInShopWebView;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ObjectDetailInShopViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_objectDetailInShopWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isEqualToString:@"deleted"]) {
            [self popAlert:@"删除商品" withMessage:@"删除成功~\(≧▽≦)/~"];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        responseCallback(@".");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/items/show.html?item_id=%@", self.objectNumber];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_objectDetailInShopWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
