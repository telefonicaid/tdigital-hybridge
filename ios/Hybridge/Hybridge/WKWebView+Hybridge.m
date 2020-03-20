//
//  WKWebView+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "WKWebView+Hybridge.h"
#import "NSString+Hybridge.h"

@implementation WKWebView (Hybridge)

- (void)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data {
    [self hyb_fireEvent:event data:data completionHandler:nil];
}

- (void)hyb_fireEvent:(NSString *)event
                 data:(NSDictionary *)data
    completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:event data:data];
    [self evaluateJavaScript:javascript completionHandler:completionHandler];
}

@end
