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

/* 
 If you name your actions using snake_case (i.e. 'your_action'), the bridge will look for a
 a method with the signature `- (void)handle<YourAction>WithData:(NSDictionary *)data` to handle
 that action.
 */

- (void)handleSomeActionWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
}

- (void)handleSomeOtherActionWithData:(NSDictionary *)data {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Send a message event back to the web view
    [self.webView hyb_fireEvent:HYBEventMessage data:@{@"method": NSStringFromSelector(_cmd)}];
}

/* If you wish to handle actions in a more generic way, you can implement:

- (NSHTTPURLResponse *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    // Handle actions here
    return nil;
}
 */

@end
