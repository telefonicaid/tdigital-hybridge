//
//  UIWebView+Hybridge.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Hybridge)

/**
 Fires a Hybridge event in the receiver.
 
 @param event The event to fire.
 @param data A dictionary containing data to pass along with the event.
 
 @return The result of firing the event.
 */
- (NSString *)hyb_fireEvent:(NSString *)event data:(NSDictionary *)data;

@end
