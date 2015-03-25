//
//  WebViewController.m
//  HybridgeSample
//
//  Created by guille on 07/04/14.
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "WebViewController.h"

@interface WebViewController () <HYBBridgeDelegate>

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Hybridge";
    self.bridge.delegate = self;
}

#pragma mark - HYBBridgeDelegate

- (NSArray *)bridgeActions:(HYBBridge *)bridge {
    return @[@"time", @"battery"];
}

#pragma mark - HYBBridgeDelegate

- (NSDictionary *)bridgeCustomData:(HYBBridge *)bridge {
    return @{@"a_custom_data": @[@"some_data", @"some_other_data"],
             @"some_other_custom": @{@"other_data": @"some_data"},
             @"more_custom": @"more_data",
             @"and_more_custom": @1};
}

/* 
 If you name your actions using snake_case (i.e. 'your_action'), the bridge will look for a
 a method with the signature `- (NSDictionary *)handle<YourAction>WithData:(NSDictionary *)data`
 to handle that action.
 */

- (NSDictionary *)handleTimeWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [outputFormatter stringFromDate:now];
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
    
    return @{
               @"time": timeString
    };
}

- (NSDictionary *)handleBatteryWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    float batteryLeft = [myDevice batteryLevel];
    NSString *batteryLevel = (batteryLeft<0.0f)? @"iOS Simulator - not available" : [NSString stringWithFormat:@"%f%%", batteryLeft];
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
    
    return @{
             @"battery": batteryLevel
    };
}

/* If you wish to handle actions in a more generic way, you can implement:

- (NSDictionary *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    // Handle actions here
    return nil;
}
*/

@end
