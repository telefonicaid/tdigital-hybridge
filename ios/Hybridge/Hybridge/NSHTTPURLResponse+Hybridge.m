//
//  NSHTTPURLResponse+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "NSHTTPURLResponse+Hybridge.h"

NSString * const HYBHostName = @"hybridge";

@implementation NSHTTPURLResponse (Hybridge)

+ (instancetype)hyb_responseWithURL:(NSURL *)url statusCode:(NSInteger)statusCode {
    NSParameterAssert(url);
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json; charset=utf-8",
        @"Access-Control-Allow-Origin": @"*",
        @"Access-Control-Allow-Headers": @"Content-Type, data"
    };
    
    return [[self alloc] initWithURL:url statusCode:statusCode HTTPVersion:@"1.1" headerFields:headers];
}

+ (instancetype)hyb_responseWithAction:(NSString *)action statusCode:(NSInteger)statusCode {
    NSParameterAssert(action);
    
    NSString *path = [NSString stringWithFormat:@"/%@", action];
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:HYBHostName path:path];
    return [self hyb_responseWithURL:url statusCode:statusCode];
}

@end
