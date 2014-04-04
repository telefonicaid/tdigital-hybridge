//
//  NSStringHybridgeTests.m
//  Hybridge
//
//  Created by guille on 04/04/14.
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Hybridge/Hybridge.h>

#import "NSString+Hybridge.h"

@interface NSStringHybridgeTests : XCTestCase

@end

@implementation NSStringHybridgeTests

- (void)testJavascriptStringWithEvent {
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:HYBEventReady data:nil];

    XCTAssertEqualObjects(@"HybridgeGlobal.fireEvent(\"ready\", {})", javascript, @"should return a fire event method call");
}

- (void)testJavascriptStringWithEventAndData {
    NSString *javascript = [NSString hyb_javascriptStringWithEvent:HYBEventMessage
                                                              data:@{ @"text": @"Testing" }];

    XCTAssertEqualObjects(@"HybridgeGlobal.fireEvent(\"message\", {\"text\":\"Testing\"})", javascript, @"should return a fire event method call");
}

@end
