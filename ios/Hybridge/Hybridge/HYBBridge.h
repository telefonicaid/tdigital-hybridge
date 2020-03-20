//
//  HYBBridge.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

@import UIKit;
@import WebKit;

@protocol HYBBridgeDelegate;

/**
 A communication bridge between the Javascript running in a `WKWebView` and the application.
 */
@interface HYBBridge : NSObject

/**
 The bridge delegate will receive actions from the visible `WKWebView`.
 */
@property (weak, nonatomic) NSObject<HYBBridgeDelegate> * _Nullable delegate;

@property (copy, nonatomic) NSString *protocol;
/**
 Returns the native bridge major version.
 */
+ (NSInteger)majorVersion;

/**
 Returns the native bridge minor version.
 */
+ (NSInteger)minorVersion;

/**
 Sets the active bridge.
 
 @param bridge The bridge that will receive actions for the visible `WKWebView`.
 */
+ (void)setActiveBridge:(HYBBridge *)bridge;

/**
 Returns active the bridge.
 */
+ (instancetype)activeBridge;

/**
 Initializes the bridge with a dispatch queue.
 This is the designated initializer.
 
 @param queue The queue that will be used to dispatch actions. If `nil` the main queue will be used.
 @return A newly initialized bridge.
 */
- (id)initWithQueue:(dispatch_queue_t)queue;

/**
 Configures a `WKWebView` to be able to communicate with this bridge.
 This method should be called after the web view has finished loading the HTML contents.
 
 @param webView The `WKWebView` to configure.
 @param scheme The forwarding requests scheme.
 @return The result of preparing the web view.
 */
- (void)prepareWebView:(WKWebView *)webView
     withRequestScheme:(NSString *)scheme
     completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

/**
 This method is called by the URL loading system when a Hybridge request is made.
 
 When this method is called, the bridge will ask its delegate to handle the action.
 
 If the delegate object implements a `- (NSDictionary *)handle<Action>WithData:(NSDictionary *)data`
 method, the bridge will call this method. The bridge assumes that action names are in snake_case,
 that is, if it receives the action 'go_to_detail' it will look for a method named
 `-handleGoToDetailWithData:`.
 
 If a method is not found, the bridge will try `-bridge:didReceiveAction:data:`. If the delegate
 does not implement neither of these methods, the bridge will return an HTTP 404 status code to the
 caller.
 
 @param action The action name.
 @param data An `NSDictionary` containing data attached to the action.
 @param completion A block that will be executed after the action has been dispatched.
 */
- (void)dispatchAction:(NSString *)action
                  data:(NSDictionary *)data
            completion:(void (^)(NSHTTPURLResponse *, NSData *))completion;

@end

/**
 Defines the bridge's delegate methods.
 */
@protocol HYBBridgeDelegate <NSObject>

@required

/**
 Returns the array of actions that the receiver can process.
 */
- (NSArray *)bridgeActions:(HYBBridge *)bridge;

/**
 Returns the dictionary of custom data.
 */
- (NSDictionary *)bridgeCustomData:(HYBBridge *)bridge;

@optional

/**
 Called when the bridge receives an action.
 
 @param action The action name.
 @param data An `NSDictionary` containing data attached to the action.
 
 @return A JSON dictionary.
 */
- (NSDictionary *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data;

@end
