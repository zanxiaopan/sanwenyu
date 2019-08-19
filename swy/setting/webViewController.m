//
//  webViewController.m
//  swy
//
//  Created by panyuwen on 2019/6/23.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:_urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.scalesPageToFit = YES;
        _webView.delegate = self;

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

#pragma mark WebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //我的区域的开放客户
    if ([webView.request.URL.absoluteString isEqualToString:@"http://sales.vemic.com/uitoolList.ui?funcID=1000931&gotoUrl=customer.do?method=operateView&isOpen=1"]) {
        [webView stringByEvaluatingJavaScriptFromString:@""];
    }
}


@end
