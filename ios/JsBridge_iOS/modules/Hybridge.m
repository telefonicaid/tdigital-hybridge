//
//  Hibridge.m
//  JsBridge_iOS
//
//  Created by David Garcia on 12/08/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "Hybridge.h"
#import "BridgeSubscriptor.h"
#import "NSURLProtocolBridge.h"

@implementation Hybridge

static NSString *version = @"1.0.0";
static Hybridge *sharedInstance = nil;

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
    }
    
    return self;
}

- (void)subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock {
    
    @try {
        [_subscriptor subscribeAction:action withHandler:handlerBlock];    }
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
    NSMutableString* ms = [[NSMutableString alloc] initWithString:@"Hybridge.fireEvent(\""];
    [ms appendString:eventName];
    [ms appendString:@"\","];
    [ms appendString:(jsonString?jsonString:@"{}")];
    [ms appendString:@")"];
    NSString *js = ms;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runJsInWebview:js web:webview];
    });
}

@end
