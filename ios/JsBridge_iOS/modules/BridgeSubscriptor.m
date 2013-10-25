//
//  BridgeSubscriptor.m
//  Hybridge_iOS
//
//  Created by Jaime on 21/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import "BridgeSubscriptor.h"

@interface BridgeSubscriptor()

@property (strong, nonatomic) NSMutableDictionary *subscriptions;

@end

@implementation BridgeSubscriptor

static BridgeSubscriptor *sharedInstance = nil;

+ (BridgeSubscriptor *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        // Initialization here
    }
    
    return self;
}

- (NSMutableDictionary *)subscriptions {
    
    if (!_subscriptions) {
        _subscriptions = [[NSMutableDictionary alloc] init];
    }
    
    return _subscriptions;
}

- (void)subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock {
    
    @try {
        [self.subscriptions setObject:handlerBlock forKey:action];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

- (void)unsubscribeAction:(NSString *)action {
    
    @try {
        [self.subscriptions removeObjectForKey:action];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

- (BOOL)isSubscribedForAction:(NSString *)action {
    
    return ([self.subscriptions objectForKey:action] != nil);
}

- (BridgeHandlerBlock_t)handlerForAction:(NSString *)action {
    
    return [self.subscriptions objectForKey:action];
}

@end
