//
//  UIWebView+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "UIWebView+Hybridge.h"
#import "NSString+Hybridge.h"

@implementation UIWebView (Hybridge)

- (NSString *)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data {
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:event data:data];
    return [self stringByEvaluatingJavaScriptFromString:javascript];
}

@end
