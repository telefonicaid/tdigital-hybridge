//
//  WebViewController.m
//  HybridgeSample
//
//  Created by guille on 07/04/14.
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
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
    return @[@"some_action", @"some_other_action"];
}

#pragma mark - HYBBridgeDelegate

- (NSDictionary *)bridgeCustom:(HYBBridge *)bridge {
    return @{@"a_custom_data": @[@"some_data", @"some_other_data"],
             @"some_other_custom": @{@"other_data": @"some_data"},
             @"more_custom": @"more_data",
             @"and_more_custom": 123456};
}

/* 
 If you name your actions using snake_case (i.e. 'your_action'), the bridge will look for a
 a method with the signature `- (NSDictionary *)handle<YourAction>WithData:(NSDictionary *)data`
 to handle that action.
 */

- (NSDictionary *)handleSomeActionWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
    
    return @{
               @"foo": @"bar"
    };
}

- (NSDictionary *)handleSomeOtherActionWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
    
    return nil;
}

/* If you wish to handle actions in a more generic way, you can implement:

- (NSDictionary *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    // Handle actions here
    return nil;
}
*/

@end
