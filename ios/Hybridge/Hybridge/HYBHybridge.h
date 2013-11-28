/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIWebView.h>

@interface HYBHybridge : NSObject

/**
 *  Current Native Hybridge version
 */
extern int const kVersion;

/**
 *  String constants referencing defined Hybridge native events
 */
extern NSString * const kHybridgeEventPause;
extern NSString * const kHybridgeEventResume;
extern NSString * const kHybridgeEventMessage;
extern NSString * const kHybridgeEventReady;

/**
 *  Defined block to be used as handler of each action.
 *
 *  @param NSURLProtocol*     Contains request information
 *  @param NSString*          JSON string sent from the Javascript call
 *  @param NSHTTPURLResponse* HTTP response
 */
typedef void (^HybridgeHandlerBlock_t)(NSURLProtocol*, NSString*, NSHTTPURLResponse*);

/**
 *	Singleton constructor
 *
 *	@return single Hibridge instance
 */
+ (HYBHybridge *)sharedInstance;

/**
 *  Returns the actual list of available native actions
 *
 *  @return list of actions
 */
- (NSDictionary *)getActions;

/**
 *  Execute Javascript code in WebView
 *
 *  @param js      Javastring code String
 *  @param webview target WebView
 *
 *  @return String returned by Javascript code.
 */
- (NSString *)runJsInWebview:(NSString *)js web:(UIWebView*) webview;

/**
 *  Trigger Hybridge event in Webview
 *
 *  @param eventName  Event type
 *  @param jsonString JSON data to attach to the event
 *  @param webview    target WebView
 */
- (void)fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview;

/**
 *  Add block handler to current list of supported native actions
 *
 *  @param action       action name
 *  @param handlerBlock handler block
 */
- (void)subscribeAction:(NSString *)action withHandler:(HybridgeHandlerBlock_t)handlerBlock;

/**
 *  Initialices Javascript HybridgeGlobal object in WebView
 *
 *  @param webview target WebView
 */
- (void)initJavascript:(UIWebView*) webview;

@end
