/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import "Hybridge.h"
#import "Constants.h"
#import "HybridgeSubscriptor.h"
#import "NSURLProtocolBridge.h"

@interface Hybridge ()

{
    HybridgeSubscriptor *_subscriptor;
    NSMutableArray *_actions;
    NSArray *_events;
}

@end

@implementation Hybridge

static Hybridge *sharedInstance = nil;

int const kVersion = kHybridgeVersion;
NSString * const kHybridgeEventPause = kEventNamePause;
NSString * const kHybridgeEventResume = kEventNameResume;
NSString * const kHybridgeEventMessage = KEventNameMessage;
NSString * const kHybridgeEventReady = kEventNameReady;

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
        _subscriptor = [HybridgeSubscriptor sharedInstance];
        _actions = [[NSMutableArray alloc] init];
        _events = @[kHybridgeEventPause,
                    kHybridgeEventResume,
                    kHybridgeEventMessage,
                    kHybridgeEventReady];
    }
    
    return self;
}

- (void)subscribeAction:(NSString *)action withHandler:(HybridgeHandlerBlock_t)handlerBlock
{
    
    @try {
        [_subscriptor subscribeAction:action withHandler:handlerBlock];
        [_actions addObject:action];
    }
    @catch (NSException * e) {
    }
}

- (NSString *)runJsInWebview:(NSString*)js web:(UIWebView*) webview
{
    NSString *jsResponse = [webview stringByEvaluatingJavaScriptFromString:js];
    return jsResponse;
}

- (void)fireEventInWebView:(NSString *)eventName data:(NSString *)jsonString web:(UIWebView*) webview
{
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
    NSError *error = nil;
    NSData *dataActions = [NSJSONSerialization dataWithJSONObject:_actions options:0 error:&error];
    NSData *dataEvents = [NSJSONSerialization dataWithJSONObject:_events options:0 error:&error];
    
    NSMutableString* js =
    [[NSMutableString alloc] initWithString:@"window.HybridgeGlobal || function () { window.HybridgeGlobal = {isReady:true,version:"];
    [js appendString:[NSString stringWithFormat:@"%d", kVersion]];
    [js appendString:@", actions:"];
    [js appendString:(dataActions ?
                      [[NSString alloc] initWithBytes:[dataActions bytes] length:[dataActions length] encoding:NSUTF8StringEncoding] : @"[]")];
    [js appendString:@", events:"];
    [js appendString:(dataEvents ?
                      [[NSString alloc] initWithBytes:[dataEvents bytes] length:[dataEvents length] encoding:NSUTF8StringEncoding] : @"[]")];
    [js appendString:@"}; window.$ && $('#hybridgeTrigger').toggleClass('switch');"];
    [js appendString:@"}()"];
    
    [self runJsInWebview:js web:webview];
}

@end
