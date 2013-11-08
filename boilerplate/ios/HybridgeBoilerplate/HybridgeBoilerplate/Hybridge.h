/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIWebView.h>

@interface Hybridge : NSObject

extern int const kVersion;

extern NSString * const kHybridgeEventPause;
extern NSString * const kHybridgeEventResume;
extern NSString * const kHybridgeEventMessage;
extern NSString * const kHybridgeEventReady;

/** Defined block to be used as handler of each action. Parameters:
 - name of action
 - list of path components in
 - data */
typedef void (^HybridgeHandlerBlock_t)(NSURLProtocol*, NSString*, NSHTTPURLResponse*);

/**
 *	Singleton consructor
 *
 *	@return	Hibridge instance
 */
+ (Hybridge *)sharedInstance;

- (NSDictionary *)getActions;

- (NSString *)runJsInWebview:(NSString *)js web:(UIWebView*) webview;

- (void)fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview;

- (void)subscribeAction:(NSString *)action withHandler:(HybridgeHandlerBlock_t)handlerBlock;

- (void)initJavascript:(UIWebView*) webview;

@end
