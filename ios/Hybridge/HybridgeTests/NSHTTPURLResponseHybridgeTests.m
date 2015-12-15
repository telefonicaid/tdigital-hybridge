//
//  NSHTTPURLResponseHybridgeTests.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import <XCTest/XCTest.h>
#import <Hybridge/Hybridge.h>

@interface NSHTTPURLResponseHybridgeTests : XCTestCase

@property (strong, nonatomic) NSDictionary *expectedHeaders;

@end

@implementation NSHTTPURLResponseHybridgeTests

- (void)setUp {
    [super setUp];

    self.expectedHeaders = @{
        @"Content-Type": @"application/json; charset=utf-8",
        @"Access-Control-Allow-Origin": @"*",
        @"Access-Control-Allow-Headers": @"Content-Type, data"
    };
}

- (void)tearDown {
    self.expectedHeaders = nil;
    [super tearDown];
}

- (void)testResponseWithURL {
    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:HYBHostName path:@"/some_action"];
    NSHTTPURLResponse *response = [NSHTTPURLResponse hyb_responseWithURL:url statusCode:200];
    
    XCTAssertEqualObjects([NSURL URLWithString:@"http://hybridge/some_action"], response.URL, @"should initialize URL");
    XCTAssertEqual((NSInteger)200, response.statusCode, @"should initialize statusCode");
    XCTAssertEqualObjects(self.expectedHeaders, response.allHeaderFields, @"should initialize headers");
}

- (void)testResponseWithAction {
    NSHTTPURLResponse *response = [NSHTTPURLResponse hyb_responseWithAction:@"some_action" statusCode:200];
    
    XCTAssertEqualObjects([NSURL URLWithString:@"https://hybridge/some_action"], response.URL, @"should initialize URL");
}

@end
