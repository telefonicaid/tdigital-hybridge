//
//  HYBBridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "HYBBridge.h"
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

+ (NSInteger)version {
    return 1;
}

+ (void)setActiveBridge:(HYBBridge *)bridge {
    // TODO: implement
}

+ (instancetype)activeBridge {
    // TODO: implement
    return nil;
}

- (void)prepareWebView:(UIWebView *)webView {
    // TODO: implement
}

- (NSHTTPURLResponse *)sendAction:(NSString *)action data:(NSDictionary *)data {
    NSParameterAssert(action);
    
    SEL selector = HYBSelectorWithAction(action);
    
    if ([self.delegate respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [self.delegate methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = self.delegate;
        invocation.selector = selector;

		[invocation invoke];
        
		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
        
		return result;
    } else if ([self.delegate respondsToSelector:@selector(bridge:didReceiveAction:data:)]) {
        return [self.delegate bridge:self didReceiveAction:action data:data];
    }
    
    return [NSHTTPURLResponse hyb_responseWithAction:action statusCode:404];
}

@end
