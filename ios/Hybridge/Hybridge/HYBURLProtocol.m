//
//  HYBURLProtocol.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "HYBURLProtocol.h"
#import "HYBBridge.h"

#import "NSHTTPURLResponse+Hybridge.h"

static NSString * const kHTTPOptionsMethod = @"OPTIONS";

@implementation HYBURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *host = [[[request URL] host] lowercaseString];
    return [host isEqualToString:HYBHostName];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    // TODO: implement
}

@end
