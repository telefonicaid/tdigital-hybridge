//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

@class HYBBridge;

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic, readonly) UIWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)webViewDidFailLoadWithError:(NSError *)error;

@end
