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
    return [host isEqualToString:HYBHostName] && ([HYBBridge activeBridge] != nil);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSHTTPURLResponse *response = nil;
    
    if (![[self.request HTTPMethod] isEqualToString:kHTTPOptionsMethod]) {
        NSArray *components = [[self.request URL] pathComponents];
        NSString *action = [components count] > 1 ? components[1] : nil;
        
        if (action) {
            NSDictionary *headers = [self.request allHTTPHeaderFields];
            NSData *data = [headers[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
            id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            response = [[HYBBridge activeBridge] sendAction:action data:JSONObject];
        } else {
            response = [NSHTTPURLResponse hyb_responseWithURL:[self.request URL] statusCode:404];
        }
    }
    
    if (!response) {
        response = [NSHTTPURLResponse hyb_responseWithURL:[self.request URL] statusCode:200];
    }
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end
