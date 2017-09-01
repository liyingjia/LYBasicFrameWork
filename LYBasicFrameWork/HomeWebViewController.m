//
//  HomeWebViewController.m
//  MyHome
//
//  Created by DHSoft on 16/8/31.
//  Copyright © 2016年 DHSoft. All rights reserved.
//

#import "HomeWebViewController.h"
#import <WebKit/WKWebView.h>
#import "NJKWebViewProgressView.h"

@interface HomeWebViewController ()
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UIWebView *webView;
}
@end

@implementation HomeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self HomeWebView];
    _progressProxy = [[NJKWebViewProgress alloc] init];
     webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)HomeWebView
{
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:webView];
    
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];

    
    if(self.AppDelegateSele == -1)
    {
          self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

- (void)back
{
    
    if(self.WebBack){
        
        self.WebBack();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)urlStr
{
    if(_urlStr == nil)
    {
        _urlStr = [NSString string];
    }
    return _urlStr;
}

@end
