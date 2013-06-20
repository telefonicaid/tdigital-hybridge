//
//  ENJAppDelegate.h
//  Enj-Mobile
//
//  Created by Aurigae on 02/10/12.
//  Copyright (c) 2012 PDI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ENJGlobal-Types.h"
#import "ENJModule-Service.h"

@class ENJSplashVC, ENJWebViewController, ENJPlayerViewController;

@interface ENJAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

/** */
@property (strong, nonatomic) UIWindow *window;
/** */
@property (strong, nonatomic) ENJSplashVC *splashVC;
/** */
@property (strong, nonatomic) ENJWebViewController *webViewVC;
@property (strong, nonatomic) ENJPlayerViewController *playerVC;

- (NSString *)getUrlForSafari;
- (NSString *)getUrlBase;

- (void)launchPlayer:(NSDictionary *)playerOptions;
- (void)launchPlayer:(NSString *)mediaUrl withCallbackRoute:(NSString *)route isTrailer:(BOOL)isTrailer;
- (void)launchWebApp:(NSString *)enjoyUrl andShowIt:(BOOL)show;

- (NetworkStatus)getCurrentNetWork;

- (NSString *)runJsInWebview:(NSString *)js andPutWebview:(BOOL)putWebview;

- (NSString *)getFirstAccessUrl;

- (void)showMessage:(NSString *)message withCancelButton:(NSString *)button andDelegate:(id)delegate;

@end
