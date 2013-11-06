/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import "BridgeSubscriptor.h"

@class SBJsonWriter;

@interface Hybridge : NSObject
{
    @private
    BridgeSubscriptor *_subscriptor;
    NSMutableArray *_actions;
    SBJsonWriter *_writer;
    NSArray *_events;
}

extern int const kVersion;

extern NSString * const kHybridgeEventPause;
extern NSString * const kHybridgeEventResume;
extern NSString * const kHybridgeEventMessage;
extern NSString * const kHybridgeEventReady;

/**
 *	Singleton consructor
 *
 *	@return	Hibridge instance
 */
+ (Hybridge *) sharedInstance;

- (NSDictionary *) getActions;

- (NSString *) runJsInWebview:(NSString *)js web:(UIWebView*) webview;

- (void) fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview;

- (void) subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock;

- (void) initJavascript:(UIWebView*) webview;

@end
