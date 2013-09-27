//
//  BridgeSubscriptor.h
//  Hybridge_iOS
//
//  Created by Jaime on 21/06/13.
//  Copyright (c) 2013 tid.es. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "MCALog.h"

/** This singleton class manages a list of subscriptions for received requests in the bridge.
 Each single subscription has an action name associated to and a handler to be called
 */
@interface BridgeSubscriptor : NSObject

/** Defined block to be used as handler of each action. Parameters: 
    - name of action
    - list of path components in
    - data */
typedef void (^BridgeHandlerBlock_t)(NSURLProtocol*, NSString*, NSHTTPURLResponse*);

/** Singleton constructor */ 
+ (BridgeSubscriptor *)sharedInstance;

/** Subscribes to action with the given handler block 
 @param action name of the action to suscribe
 @param handlerBlock handler to be called when a request arrives with the given action */
- (void)subscribeAction:(NSString *)action withHandler:(BridgeHandlerBlock_t)handlerBlock;

/** Unsubscribes to action 
 @param action name of the action to unsubscribe */
- (void)unsubscribeAction:(NSString *)action;

/** Checks if the action is currently subscribed
 @param action name of the action to check 
 @return YES if the action is already subscribed, NO otherwise*/
- (BOOL)isSubscribedForAction:(NSString *)action;

/** Returns the handler associated to the given handler
 @param action name of the action to return its handler
 @return handler associated to the given action, or nil if there is no subscriptios */
- (BridgeHandlerBlock_t)handlerForAction:(NSString *)action;
 
@end
