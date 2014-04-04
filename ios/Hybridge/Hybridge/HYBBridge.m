//
//  HYBBridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "HYBBridge.h"
#import "HYBURLProtocol.h"
#import "HYBEvent.h"

#import "NSString+Hybridge.h"
#import "NSHTTPURLResponse+Hybridge.h"

static SEL HYBSelectorWithAction(NSString *action) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *selectorNames;
    
    dispatch_once(&onceToken, ^{
        selectorNames = [NSMutableDictionary dictionary];
    });
    
    NSString *selectorName = selectorNames[action];
    
    if (!selectorName) {
        // Convert the action name to CamelCase
        NSArray *components = [action componentsSeparatedByString:@"_"];
        NSMutableArray *mutableComponents = [NSMutableArray arrayWithCapacity:[components count]];
        [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mutableComponents addObject:[obj capitalizedString]];
        }];
        action = [mutableComponents componentsJoinedByString:@""];
        
        // Cache the selector name
        selectorName = [NSString stringWithFormat:@"handle%@WithData:", action];
        selectorNames[action] = selectorName;
    }
    
    return NSSelectorFromString(selectorName);
}

@implementation HYBBridge

+ (void)initialize {
    if (self == [HYBBridge class]) {
        [NSURLProtocol registerClass:[HYBURLProtocol class]];
    }
}

+ (NSInteger)version {
    return 1;
}

static HYBBridge *activeBridge;

+ (void)setActiveBridge:(HYBBridge *)bridge {
    activeBridge = bridge;
}

+ (instancetype)activeBridge {
    return activeBridge;
}

- (NSString *)prepareWebView:(UIWebView *)webView {
    NSParameterAssert(webView);
    
    static NSString * const kFormat = @"window.HybridgeGlobal || setTimeout(function() {"
                                      @"	window.HybridgeGlobal = {"
                                      @"		isReady:true,"
                                      @"		version:%@,"
                                      @"		actions:%@,"
                                      @"		events:%@"
                                      @"	};"
                                      @"	window.$ && $('#hybridgeTrigger').toggleClass('switch');"
                                      @"}, 0)";
    
    NSArray *actions = [self.delegate bridgeActions:self];
    NSString *actionsString = [NSString hyb_JSONStringWithObject:actions ? : @[]];
    
    NSArray *events = @[HYBEventPause, HYBEventResume, HYBEventMessage, HYBEventReady];
    NSString *eventsString = [NSString hyb_JSONStringWithObject:events];
    
    NSString *javascript = [NSString stringWithFormat:kFormat, @([[self class] version]), actionsString, eventsString];
    return [webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (NSHTTPURLResponse *)sendAction:(NSString *)action data:(NSDictionary *)data {
    NSParameterAssert(action);
    
    SEL selector = HYBSelectorWithAction(action);
    
    if ([self.delegate respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [self.delegate methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = self.delegate;
        invocation.selector = selector;
        [invocation setArgument:&data atIndex:2];
        
		[invocation invoke];
        
		return [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
    } else if ([self.delegate respondsToSelector:@selector(bridge:didReceiveAction:data:)]) {
        return [self.delegate bridge:self didReceiveAction:action data:data];
    }
    
    return [NSHTTPURLResponse hyb_responseWithAction:action statusCode:404];
}

@end
