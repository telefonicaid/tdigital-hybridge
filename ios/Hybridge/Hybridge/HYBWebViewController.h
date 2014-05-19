//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

@protocol HYBWebViewControllerDelegate;
@class HYBBridge;

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) id<HYBWebViewControllerDelegate> delegate;
@property (strong, nonatomic, readonly) UIWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

@end

@protocol HYBWebViewControllerDelegate <NSObject>

@optional

- (void)webControllerDidStartLoad:(HYBWebViewController *)controller;
- (void)webControllerDidFinishLoad:(HYBWebViewController *)controller;
- (void)webController:(HYBWebViewController *)controller didFailLoadWithError:(NSError *)error;

@end
