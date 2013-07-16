//
//  JsBridgeAppDelegate.h
//  JsBridge_iOS
//
//  Created by David Garcia on 11/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@interface JsBridgeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WebViewController *viewController;

@end
