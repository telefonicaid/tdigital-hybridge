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
    // TODO: implement
    return @[@"init", @"someAction", @"someOtherAction"];
}

- (void)handleInitWithData:(NSDictionary *)data {
    NSLog(@"init");
    
    if ([data[@"initialized"] boolValue]) {
        [self.webView hyb_fireEvent:HYBEventReady data:nil];
    }
}

- (NSHTTPURLResponse *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    NSLog(@"action: %@ data: %@", action, data);
    // For the sake of the sample, we send "message" events with the action data
    [self.webView hyb_fireEvent:HYBEventMessage data:data];
    return nil;
}

@end
