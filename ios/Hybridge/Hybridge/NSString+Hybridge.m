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
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:data ? : @{}
                                                       options:0
                                                         error:NULL];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:kFormat, event, JSONString];
}

@end
