#import <Foundation/Foundation.h>

@class NativeAction;
@protocol JsBridgeDelegate;

@interface JsBridgeURLInterceptor : NSURLCache {
    id <JsBridgeDelegate> __weak mDelegate;
}

@property(weak) id <JsBridgeDelegate> delegate;

@end


@protocol JsBridgeDelegate <NSObject>
- (NSDictionary *)handleAction:(NativeAction *)action error:(NSError **)error;
@end


@interface NSURLCache (JsBridge)
+ (id <JsBridgeDelegate>)jsBridgeDelegate;

+ (void)setJsBridgeDelegate:(id <JsBridgeDelegate>)delegate;
@end