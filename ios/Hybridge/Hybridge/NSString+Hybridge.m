//
//  NSString+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "NSString+Hybridge.h"

@implementation NSString (Hybridge)

+ (instancetype)hyb_javascriptStringWithEvent:(NSString *)event data:(NSDictionary *)data {
    NSParameterAssert(event);
    
    static NSString * const kFormat = @"HybridgeGlobal.fireEvent(\"%@\", %@)";
    
    NSString *JSONString = [self hyb_JSONStringWithObject:data ? : @{}];
    return [NSString stringWithFormat:kFormat, event, JSONString];
}

+ (instancetype)hyb_JSONStringWithObject:(id)object {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
    return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
}

@end
