//
//  Hibridge.h
//  JsBridge_iOS
//
//  Created by David Garcia on 12/08/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

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
    
    @public
    NSString *EVENT_PAUSE;
    NSString *EVENT_RESUME;
    NSString *EVENT_MESSAGE;
    NSString *EVENT_READY;
}

extern const int VERSION;

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
