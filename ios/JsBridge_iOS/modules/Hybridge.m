//
//  Hibridge.m
//  JsBridge_iOS
//
//  Created by David Garcia on 12/08/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "Hybridge.h"
#import "Constants.h"
#import "SBJson.h"
#import "BridgeSubscriptor.h"
#import "NSURLProtocolBridge.h"

@implementation Hybridge

static Hybridge *sharedInstance = nil;

const int VERSION = HybridgeVersion;
const NSString *EVENT_PAUSE = EV_PAUSE;
const NSString *EVENT_RESUME = EV_RESUME;
const NSString *EVENT_MESSAGE = EV_MESSAGE;
const NSString *EVENT_READY = EV_READY;


+ (Hybridge *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [NSURLProtocol registerClass:[NSURLProtocolBridge class]];
        _subscriptor = [BridgeSubscriptor sharedInstance];  
        _actions = [[NSMutableArray alloc] init];
        _writer = [[SBJsonWriter alloc] init];
        _events = @[ EVENT_PAUSE, EVENT_RESUME, EVENT_MESSAGE, EVENT_READY ];
        
    }
    
    return self;
}

- (void)subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock
{
    
    @try {
        [_subscriptor subscribeAction:action withHandler:handlerBlock];
        [_actions addObject:action];
    }
    @catch (NSException * e) {
        DDLogError(@"Exception: %@", e);
    }
}

- (NSString *)runJsInWebview:(NSString*)js web:(UIWebView*) webview
{
    DDLogInfo(@"runJsInWebview: %@",js);
    NSString *jsResponse = [webview stringByEvaluatingJavaScriptFromString:js];
    DDLogInfo(@"runJsInWebview response: %@",jsResponse);
    return jsResponse;
}

- (void)fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview
{
    DDLogInfo(@"Enviando evento a Webview: %@", eventName);
    NSMutableString* ms = [[NSMutableString alloc] initWithString:@"HybridgeGlobal.fireEvent(\""];
    [ms appendString:eventName];
    [ms appendString:@"\","];
    [ms appendString:(jsonString?jsonString:@"{}")];
    [ms appendString:@")"];
    NSString *js = ms;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runJsInWebview:js web:webview];
    });
}

- (NSArray *)getActions
{
    return [NSArray arrayWithArray:_actions];
}

- (void)initJavascript:(UIWebView*) webview
{
    NSString *actionsStr = [_writer stringWithObject:_actions];
    NSString *eventsStr = [_writer stringWithObject:_events];
    NSMutableString* js = [[NSMutableString alloc] initWithString:@"HybridgeGlobal={isReady:true,version:"];
    [js appendString:[NSString stringWithFormat:@"%d", VERSION]];
    [js appendString:@",actions:"];
    [js appendString:(actionsStr ? actionsStr : @"[]")];
    [js appendString:(eventsStr ? eventsStr : @"[]")];
    [js appendString:@"}"];
    [js appendString:@";window.$&&$('#hybridgeTrigger').toggleClass('switch');"];
    
    
    [self runJsInWebview:js web:webview];
}

@end
