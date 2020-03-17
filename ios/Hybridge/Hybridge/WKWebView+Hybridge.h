//
//  UIWebView+Hybridge.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

@import WebKit;

@interface WKWebView (Hybridge)

/**
 Fires a Hybridge event in the receiver.
 
 @param event The event to fire.
 @param data A dictionary containing data to pass along with the event.
 
 @return The result of firing the event.
 */
- (void)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data;

/**
Fires a Hybridge event in the receiver.

@param event The event to fire.
@param data A dictionary containing data to pass along with the event.
@param compeltionHandler A funciton to run as compleiton of js evaluation.
@return The result of firing the event.
*/
- (void)hyb_fireEvent:(NSString *_Nonnull)event
                 data:(NSDictionary *)data
    completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

@end
