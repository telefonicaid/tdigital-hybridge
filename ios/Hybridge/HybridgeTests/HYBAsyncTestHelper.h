//
//  HYBAsyncTestHelper.h
//
//  Created by guille on 23/09/13.
//  Copyright (c) 2013 Guillermo Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HYB_RUNLOOP_INTERVAL 0.05
#define HYB_TIMEOUT_INTERVAL 1.0
#define HYB_RUNLOOP_COUNT HYB_TIMEOUT_INTERVAL / HYB_RUNLOOP_INTERVAL

#define HYB_CAT(x, y) x ## y
#define HYB_TOKCAT(x, y) HYB_CAT(x, y)
#define __runLoopCount HYB_TOKCAT(__runLoopCount,__LINE__)

#define HYBAssertEventually(a1, format...) \
NSUInteger __runLoopCount = 0; \
while (!(a1) && __runLoopCount < HYB_RUNLOOP_COUNT) { \
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:HYB_RUNLOOP_INTERVAL]; \
    [NSRunLoop.currentRunLoop runUntilDate:date]; \
    __runLoopCount++; \
} \
if (__runLoopCount >= HYB_RUNLOOP_COUNT) { \
    XCTFail(format); \
}
