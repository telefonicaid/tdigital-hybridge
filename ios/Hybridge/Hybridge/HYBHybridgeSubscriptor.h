/**
 * Hybridge
 * (c) Telefonica Digital, 2013 - All rights reserved
 * License: GNU Affero V3 (see LICENSE file)
 */

#import <Foundation/Foundation.h>
#import "HYBHybridge.h"

/** This singleton class manages a list of subscriptions for received requests in the bridge.
 Each single subscription has an action name associated to and a handler to be called
 */
@interface HYBHybridgeSubscriptor : NSObject

/** Singleton constructor */ 
+ (HYBHybridgeSubscriptor *)sharedInstance;

/** Subscribes to action with the given handler block 
 @param action name of the action to suscribe
 @param handlerBlock handler to be called when a request arrives with the given action */
- (void)subscribeAction:(NSString *)action withHandler:(HybridgeHandlerBlock_t)handlerBlock;

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
- (HybridgeHandlerBlock_t)handlerForAction:(NSString *)action;
 
@end
