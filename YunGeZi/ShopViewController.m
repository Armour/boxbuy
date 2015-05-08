//
//  ShopViewController.m
//  YunGeZi
//
//  Created by Armour on 5/8/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ShopViewController.h"
#import "WebViewJavascriptBridge.h"
#import "ObjectDetailInShopViewController.h"

@interface ShopViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *shopWebView;
@property (strong, nonatomic) NSString *objectNumber;
@property WebViewJavascriptBridge* bridge;

@end

@implementation ShopViewController

- (void)webViewBridge {
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_shopWebView handler:^(id data, WVJBResponseCallback responseCallback) {
        self.objectNumber = data;
        [self performSegueWithIdentifier:@"showDetailInShop" sender:self];
        responseCallback(self.objectNumber);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self webViewBridge];
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"http://webapp-ios.boxbuy.cc/indexschool.html?sellerid=%@", self.userid];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_shopWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showDetailInShop"]) {
        ObjectDetailInShopViewController *controller = (ObjectDetailInShopViewController *)segue.destinationViewController;
        [controller setObjectNumber:self.objectNumber];
    }
}

@end
