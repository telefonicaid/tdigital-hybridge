//
//  NSURLProtocolBridge.m
//  Hybridge_iOS
//
//  Created by David Garcia on 12/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "NSURLProtocolBridge.h"
#import "NativeAction.h"
#import "SBJson.h"
#import "BridgeSubscriptor.h"

@implementation NSURLProtocolBridge

NSString *bridgePrefix = @"hybridge";

+ (BOOL)canInitWithRequest:(NSURLRequest *)_request
{
    if ([[_request HTTPMethod] caseInsensitiveCompare:@"OPTIONS"] == NSOrderedSame ||
        [_request.URL.host caseInsensitiveCompare:bridgePrefix] == NSOrderedSame)
    {
        return YES;
    }
    return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest *)_request
{
    return _request;
}

- (void)startLoading
{
    
    if([[self.request HTTPMethod] caseInsensitiveCompare:@"OPTIONS"] == NSOrderedSame)
    {
        DDLogInfo(@"Response OPTIONS prefight request");
        BridgeHandlerBlock_t handler = [[BridgeSubscriptor sharedInstance] handlerForAction:@"preflight"];
        handler(self, nil);
        return;
    }
    parser = [[SBJsonParser alloc] init];
    writer = [[SBJsonWriter alloc] init];
    
    /** Decode REST URL ( http://hybridge/action/id ) */
    NSString *_action = nil;
    NSString *_id = nil;
    if ([[self.request.URL pathComponents] count] > 1) {
        _action = [[self.request.URL pathComponents] objectAtIndex:1];
        _id = [[self.request.URL pathComponents] objectAtIndex:2];
    }
    DDLogInfo(@"%@ / %@", _action, _id);
    
    /** Get header data (JSON) */
    NSDictionary *headers = [self.request allHTTPHeaderFields];
    NSString *_data = [headers objectForKey:@"data"];
    NSDictionary *params = [parser objectWithString:_data];
    
    // Look for a handler subscribed for this action
    BridgeHandlerBlock_t handler = [[BridgeSubscriptor sharedInstance] handlerForAction:_action];
    
    if (handler != nil) {
        handler(self, _data);
        
    } else {
    
        /** TODO: Connect to internal service to take required actions:
            Download file, fetch local file info, play video
         */
        // Crear un objeto NativeAction para transportar la petición al manejador nativo
        //NativeAction *nativeAction = [[NativeAction alloc] initWithAction:_action params:params];
        //NSError *error = nil;
        //NSMutableDictionary *result = [[self.delegate handleAction:nativeAction error:&error] mutableCopy];
        
        /** Create JSON response */
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        NSString *ts = [json objectForKey:@"timestamp"];
        [json setValue:ts  forKey:@"data"];
        [json setValue:@"application/json; charset=utf-8" forKey:@"Content-Type"];
        [json setValue:@"*" forKey:@"Access-Control-Allow-Origin"];
        [json setValue:@"Content-Type" forKey:@"Access-Control-Allow-Headers"];
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:json];

        NSString *jsonString = [writer stringWithObject:params];
        NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];    
        
        id client = [self client];    
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:jsonBody];
        [client URLProtocolDidFinishLoading:self];
        
    }
}

- (void)stopLoading
{
}

@end
