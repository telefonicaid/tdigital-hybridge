//
//  JsBridgeAppDelegate.m
//  JsBridge_iOS
//
//  Created by David Garcia on 11/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "JsBridgeAppDelegate.h"
#import "NativeAction.h"
#import "WebViewController.h"

@implementation JsBridgeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  setenv("XcodeColors", "YES", 1);
  // Configure CocoaLumberjack
  ////[DDLog addLogger:[DDASLLogger sharedInstance]];
  ////[DDLog addLogger:[DDTTYLogger sharedInstance]];
  // Enable Colors
  //Define green color for info level
  ////[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

  //UIColor *greenColor = [UIColor colorWithRed:(0/255.0) green:(158/255.0) blue:(71/255.0) alpha:1.0];
  //UIColor *orangeColor = [UIColor colorWithRed:(255.0/255.0) green:(127.5/255.0) blue:(0/255.0) alpha:1.0];
  //UIColor *redColor = [UIColor colorWithRed:(255.0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
  
  //[[DDTTYLogger sharedInstance] setForegroundColor:greenColor backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
  //[[DDTTYLogger sharedInstance] setForegroundColor:orangeColor backgroundColor:nil forFlag:LOG_FLAG_WARN];
  //[[DDTTYLogger sharedInstance] setForegroundColor:redColor backgroundColor:nil forFlag:LOG_FLAG_ERROR];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  self.viewController = [[WebViewController alloc] init];
  self.window.rootViewController = self.viewController;
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  NSLog(@"La applicación pasó a segundo plano");
  [self.viewController fireJavascriptEvent: (NSString*) @"pause" data:(NSString*) [self getTimestampJSON]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  NSLog(@"La applicación pasó a primer plano");
  [self.viewController fireJavascriptEvent: (NSString*) @"resume" data:(NSString*) [self getTimestampJSON]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSDictionary *)handleAction:(NativeAction *)nativeAction error:(NSError **)error
{
  return nil;
}

- (NSString *) getTimestampJSON
{
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  NSNumber *timeStampNum = [NSNumber numberWithDouble: timeStamp];
  NSString* ts = [NSString stringWithFormat:@"%@", timeStampNum];
  NSMutableString* ms = [[NSMutableString alloc] initWithString:@"{\"timestamp\":"];
  [ms appendString:ts];
  [ms appendString:@"}"];
  return ms;
}

@end
