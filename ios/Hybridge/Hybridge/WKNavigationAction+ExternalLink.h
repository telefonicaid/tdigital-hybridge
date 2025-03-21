//
//  WKNavigationAction+ExternalLink.h
//  Hybridge
//
//  Created by Diego Olmo Cejudo on 18/3/25.
//  Copyright © 2025 Telefonica I+D. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKNavigationAction (ExternalLink)

- (BOOL)openExternalLinkIfNeeded;

@end
