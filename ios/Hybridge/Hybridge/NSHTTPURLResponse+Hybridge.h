//
//  NSHTTPURLResponse+Hybridge.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <Foundation/Foundation.h>

extern NSString * const HYBHostName;

@interface NSHTTPURLResponse (Hybridge)

/**
 Creates and returns a Hybridge response for a given url.
 
 @param url The URL from which the response was generated.
 @param statusCode The HTTP status code to return.
 
 @return An initialized `NSHTTPURLResponse` or `nil` if an error occurred.
 */
+ (instancetype)hyb_responseWithURL:(NSURL *)url statusCode:(NSInteger)statusCode;

/**
 Creates and returns a Hybridge response for a given action.
 
 @param action The action from which the response was generated.
 @param statusCode The HTTP status code to return.
 
 @return An initialized `NSHTTPURLResponse` or `nil` if an error occurred.
 */
+ (instancetype)hyb_responseWithAction:(NSString *)action statusCode:(NSInteger)statusCode;

@end
