//
//  WKNavigationAction+ExternalLink.m
//  Hybridge
//
//  Created by Diego Olmo Cejudo on 18/3/25.
//  Copyright © 2025 Telefonica I+D. All rights reserved.
//

#import "WKNavigationAction+ExternalLink.h"
#import <UIKit/UIKit.h>

@implementation WKNavigationAction (ExternalLink)

- (BOOL)openExternalLinkIfNeeded {
    NSURL *url = self.request.URL;
    if (url && self.targetFrame == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        });
        return YES;
    }
    return NO;
}

@end
