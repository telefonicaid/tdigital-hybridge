//
//  HYBWebViewController.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "HYBWebViewController.h"
#import "HYBBridge.h"

@interface HYBWebViewController ()

@property (strong, nonatomic) NSURL *URL;

@end

@implementation HYBWebViewController

#pragma mark - Properties

- (WKWebView *)webView {
    return (WKWebView *)self.view;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.navigationDelegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _bridge = [[HYBBridge alloc] init];
        _bridge.delegate = self;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        _URL = url;
    }
    
    return self;
}

- (void)loadView {
    if ([self nibName]) {
        [super loadView];
        NSAssert([self.view isKindOfClass:[WKWebView class]], @"HYBWebViewController view must be a UIWebView instance.");
    } else {
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addScriptMessageHandler:self name:@"hybridge"];
        
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = userContentController;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                configuration:configuration];
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view = webView;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.URL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [HYBBridge setActiveBridge:self.bridge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.bridge == [HYBBridge activeBridge]) {
        [HYBBridge setActiveBridge:nil];
    }
}

- (void)webViewDidStartLoad {
}

- (void)webViewDidFinishLoad {
}

- (void)webViewDidFailLoadWithError:(NSError *)error {
}

#pragma mark - WKNavigationDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self webViewDidStartLoad];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.bridge prepareWebView:webView withRequestScheme:self.webView.URL.scheme completionHandler:nil];
    [self webViewDidFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFailLoadWithError:error];
}

#pragma mark - HYBBridgeDelegate

- (NSArray *)bridgeActions:(HYBBridge *)bridge {
    return nil;
}

#pragma mark - WKUIDelegate

- (void)                        webView:(WKWebView *)webView
  runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                            defaultText:(NSString *)defaultText
                       initiatedByFrame:(WKFrameInfo *)frame
                      completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    NSString *action = prompt;
    NSData *promptData = [defaultText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:promptData options:0 error:NULL];
    if (data) {
        if (data[@"action"]) {
            [HYBBridge.activeBridge dispatchAction:action
                                              data:data
                                        completion:^(NSHTTPURLResponse *response, NSData *data) {
                if (response.statusCode == 200) {
                    NSString *responseData = @"";
                    if (data) {
                        responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    }
                    completionHandler(responseData);
                } else {
                    completionHandler(nil);
                }
            }];
        }
    }
}
@end
