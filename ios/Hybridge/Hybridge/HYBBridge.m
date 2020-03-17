//
//  HYBBridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "HYBBridge.h"
#import "HYBEvent.h"

#import "NSString+Hybridge.h"
#import "NSHTTPURLResponse+Hybridge.h"
#import "WKWebView+Hybridge.h"

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

static NSDictionary *HYBSendAction(NSString *action,
                                   NSDictionary *data,
                                   NSObject<HYBBridgeDelegate> *delegate,
                                   NSHTTPURLResponse *__autoreleasing *response)
{
    SEL selector = HYBSelectorWithAction(action);
    
    if ([delegate respondsToSelector:selector]) {
        *response = [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
        
        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = delegate;
        invocation.selector = selector;
        [invocation setArgument:&data atIndex:2];
        
		[invocation invoke];
        
        __unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
    } else if ([delegate respondsToSelector:@selector(bridgeDidReceiveAction:data:)]) {
        *response = [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
        return [delegate bridgeDidReceiveAction:action data:data];
    }
    
    *response = [NSHTTPURLResponse hyb_responseWithAction:action statusCode:404];
    return nil;
}

@interface HYBBridge ()

@property (strong, nonatomic) dispatch_queue_t queue;
@property (weak, nonatomic) WKWebView *webView;

@end

@implementation HYBBridge

+ (void)initialize {
    if (self == [HYBBridge class]) { }
}

+ (NSInteger)majorVersion {
    return 1;
}

+ (NSInteger)minorVersion {
    return 4;
}

static HYBBridge *activeBridge;

+ (void)setActiveBridge:(HYBBridge *)bridge {
    @synchronized(self) {
        activeBridge = bridge;
    }
}

+ (instancetype)activeBridge {
    @synchronized(self) {
        return activeBridge;
    }
}

- (id)init {
    return [self initWithQueue:nil];
}

- (id)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    
    if (self) {
        self.queue = queue ? : dispatch_get_main_queue();
    }
    
    return self;
}

- (void)prepareWebView:(WKWebView *)webView
     withRequestScheme:(NSString *)scheme
     completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    NSParameterAssert(webView);
    
    self.webView = webView;
    self.protocol = scheme;
    
    static NSString * const kFormat = @"window.HybridgeGlobal || setTimeout(function() {"
                                      @"    window.HybridgeGlobal = {"
                                      @"        isReady:true,"
                                      @"        version:%@,"
                                      @"        versionMinor:%@,"
                                      @"        customData:%@,"
                                      @"        actions:%@,"
                                      @"        events:%@"
                                      @"    };"
                                      @"}, 0);";
    
    NSArray *actions = [@[@"init"] arrayByAddingObjectsFromArray:[self.delegate bridgeActions:self]];
    NSString *actionsString = [NSString hyb_JSONStringWithObject:actions];
    
    NSArray *events = @[HYBEventPause, HYBEventResume, HYBEventMessage, HYBEventReady];
    NSString *eventsString = [NSString hyb_JSONStringWithObject:events];

    NSDictionary *customData = [self.delegate bridgeCustomData:self];
    NSString *customDataString = [NSString hyb_JSONStringWithObject:customData];

    NSString *javascript = [NSString stringWithFormat:kFormat, @([[self class] majorVersion]), @([[self class] minorVersion]), customDataString, actionsString, eventsString];
    [webView evaluateJavaScript:javascript completionHandler:completionHandler];
}

- (void)dispatchAction:(NSString *)action
                  data:(NSDictionary *)data
            completion:(void (^)(NSHTTPURLResponse *, NSData *))completion
{
    NSParameterAssert(action);
    NSParameterAssert(completion);
    
    // Automatically respond to 'init' actions. Dispatch other actions to the delegate.
    
    if ([action isEqualToString:@"init"] && self.webView) {
        WKWebView *webView = self.webView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView hyb_fireEvent:HYBEventReady data:nil];
        });
        
        NSHTTPURLResponse *response = [NSHTTPURLResponse hyb_responseWithAction:action statusCode:200];
        completion(response, nil);
    } else {
        NSObject<HYBBridgeDelegate> *delegate = self.delegate;
        dispatch_async(self.queue, ^{
            NSHTTPURLResponse *response = nil;
            NSDictionary *result = HYBSendAction(action, data, delegate, &response);
            NSData *resultData = nil;
            
            if (result) {
                NSError *error = nil;
                resultData = [NSJSONSerialization dataWithJSONObject:result
                                                             options:0
                                                               error:&error];
                if (error) {
                    NSLog(@"%s JSON serialization error: %@", __PRETTY_FUNCTION__, error);
                }
            }
            
            completion(response, resultData);
        });
    }
}

@end
