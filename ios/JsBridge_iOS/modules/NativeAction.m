#import "NativeAction.h"


@implementation NativeAction

- (id)initWithAction:(NSString *)action params:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.action = action;
        mParams = params;
    }
    return self;
}

+ (id)objectWithAction:(NSString *)action params:(NSDictionary *)params {
    return [[NativeAction alloc] initWithAction:action params:params];
}

- (NSString *)action {
    return mAction;
}

- (void)setAction:(NSString *)action {
    if (mAction != action) {
        mAction = [action lowercaseString];
    }

}

@end