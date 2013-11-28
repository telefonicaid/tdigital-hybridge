/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import "HYBHybridge.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (strong) UIWebView *webview;

- (void) fireJavascriptEvent:(NSString *)eventName data:(NSString *)jsonString;

@end

