/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import "Hybridge.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>
{

@private
    Hybridge *_hybridge;
}

@property (strong) UIWebView *webview;

- (void) fireJavascriptEvent:(NSString *)eventName data:(NSString *)jsonString;

@end

