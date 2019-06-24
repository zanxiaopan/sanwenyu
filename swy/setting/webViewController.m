//
//  webViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/23.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "webViewController.h"
#import <WebKit/WebKit.h>

@interface webViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:_urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];

    }
    return _webView;
}

- (void)setUrlStr:(NSString *)urlStr
{
    _urlStr = urlStr;
    NSURL *url = [NSURL URLWithString:urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
