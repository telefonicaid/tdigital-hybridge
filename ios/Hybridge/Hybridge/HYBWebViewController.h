//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

@import UIKit;
@import WebKit;

#import "HYBBridge.h"

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <WKNavigationDelegate, WKScriptMessageHandler, HYBBridgeDelegate>

@property (strong, nonatomic, readonly) WKWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)webViewDidFailLoadWithError:(NSError *)error;

@end
