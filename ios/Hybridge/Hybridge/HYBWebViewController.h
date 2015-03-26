//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2015 Telefonica Digital. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

#import "HYBBridge.h"

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <UIWebViewDelegate, HYBBridgeDelegate>

@property (strong, nonatomic, readonly) UIWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)webViewDidFailLoadWithError:(NSError *)error;

@end
