#import <Foundation/Foundation.h>

@interface NativeAction : NSObject {
    NSString *mAction;
    NSDictionary *mParams;
}

@property(copy) NSString *action;
@property(strong) NSDictionary *params;

- (id)initWithAction:(NSString *)action params:(NSDictionary *)params;

+ (id)objectWithAction:(NSString *)action params:(NSDictionary *)params;

@end