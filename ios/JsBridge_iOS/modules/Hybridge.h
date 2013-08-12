//
//  Hibridge.h
//  JsBridge_iOS
//
//  Created by David Garcia on 12/08/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BridgeSubscriptor.h"

@interface Hybridge : NSObject
{
    @private BridgeSubscriptor *_subscriptor;
}

/**
 *	Singleton consructor
 *
 *	@return	Hibridge instance
 */
+ (Hybridge *)sharedInstance;

- (NSString *) runJsInWebview:(NSString *)js web:(UIWebView*) webview;

- (void) fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview;

- (void)subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock;
@end
