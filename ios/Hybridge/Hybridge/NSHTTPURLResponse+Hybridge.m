//
//  NSHTTPURLResponse+Hybridge.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "NSHTTPURLResponse+Hybridge.h"

#import "HYBBridge.h"

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
    NSString *requestScheme = @"https";
    if ([[HYBBridge activeBridge] protocol]) {
        requestScheme = [[HYBBridge activeBridge] protocol];
    }
    NSString *path = [NSString stringWithFormat:@"/%@", action];
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = requestScheme;
    components.host = HYBHostName;
    components.path = path;
    
    NSURL *url = components.URL;
    return [self hyb_responseWithURL:url statusCode:statusCode];
}

@end
