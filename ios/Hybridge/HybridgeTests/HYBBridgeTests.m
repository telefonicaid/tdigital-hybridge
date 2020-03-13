//
//  HYBBridgeTests.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under MIT, see LICENSE for more details.
//

#import "HYBTestCase.h"
#import "HYBAsyncTestHelper.h"

@interface HYBBridgeTests : HYBTestCase <HYBBridgeDelegate>

@property (nonatomic) BOOL didReceiveActionCalled;
@property (nonatomic) BOOL handlerCalled;

@end

@implementation HYBBridgeTests

- (void)setUp {
    [super setUp];
    
    self.didReceiveActionCalled = NO;
    self.handlerCalled = NO;
}

- (void)tearDown {
    [HYBBridge setActiveBridge:nil];
    [super tearDown];
}

- (void)testVersion {
    XCTAssertEqual((NSInteger)1, [HYBBridge majorVersion], @"should return the right major version");
}

- (void)testVersionMinor {
    XCTAssertEqual((NSInteger)3, [HYBBridge minorVersion], @"should return the right minor version");
}

- (void)testActiveBridge {
    HYBBridge *bridge = [HYBBridge new];
    [HYBBridge setActiveBridge:bridge];
    
    XCTAssertEqualObjects(bridge, [HYBBridge activeBridge], @"should return the active bridge");
}

- (void)testPrepareWebView {
    id webView = [self autoVerifiedMockForClass:[UIWebView class]];
    
    NSString *javascript = @"window.HybridgeGlobal || setTimeout(function() {"
                           @"    window.HybridgeGlobal = {"
                           @"        isReady:true,"
                           @"        version:1,"
                           @"        versionMinor:3,"
                           @"        customData:{\"test\":{\"foo\":\"bar\"}},"
                           @"        actions:[\"init\",\"test\",\"do_something\"],"
                           @"        events:[\"pause\",\"resume\",\"message\",\"ready\"]"
                           @"    };"
                           @"}, 0);";
    
    [[[webView expect] andReturn:@"true"] stringByEvaluatingJavaScriptFromString:javascript];
    
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;

    [bridge prepareWebView:webView withRequestScheme:@"hybridge" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        XCTAssertEqualObjects(@"true", result, @"should return the value returned by the web view");
    }];
    
}

- (void)testActionDispatch {
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;
    
    [HYBBridge setActiveBridge:bridge];
    
    NSURL *url = [NSURL URLWithString:@"http://hybridge/test"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"{\"foo\":\"bar\"}" forHTTPHeaderField:@"data"];
    
    NSHTTPURLResponse * __block response = nil;
    NSData * __block resultData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *data, NSError *error) {
                               response = (NSHTTPURLResponse *)r;
                               resultData = data;
                           }];
    HYBAssertEventually(response, @"should complete with a response");
    
    XCTAssertTrue(self.didReceiveActionCalled, @"should call the delegate");
    XCTAssertEqual((NSInteger)200, [response statusCode], @"should return 200 OK");
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:NULL];
    XCTAssertEqualObjects((@{@"result": @1}), result, @"should return the dictionary returned by the delegate");
}

- (void)testActionDispatchWithMethodHandler {
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;
    
    [HYBBridge setActiveBridge:bridge];
    
    NSURL *url = [NSURL URLWithString:@"http://hybridge/do_something"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"{\"bar\":\"foo\"}" forHTTPHeaderField:@"data"];
    
    NSHTTPURLResponse * __block response = nil;
    NSData * __block resultData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *data, NSError *error) {
                               response = (NSHTTPURLResponse *)r;
                               resultData = data;
                           }];
    HYBAssertEventually(response, @"should complete with a response");
    
    XCTAssertTrue(self.handlerCalled, @"should call the handler method");
    XCTAssertEqual((NSInteger)200, [response statusCode], @"should return 200 OK");
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:NULL];
    XCTAssertEqualObjects((@{@"result": @2}), result, @"should return the dictionary returned by the delegate");
}

- (void)testUnhandledAction {
    HYBBridge *bridge = [HYBBridge new];
    [HYBBridge setActiveBridge:bridge];
    
    NSURL *url = [NSURL URLWithString:@"http://hybridge/unhandled_action"];
    
    NSHTTPURLResponse * __block response = nil;
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *data, NSError *error) {
                               response = (NSHTTPURLResponse *)r;
                           }];
    HYBAssertEventually(response, @"should complete with a response");
    XCTAssertEqual((NSInteger)404, [response statusCode], @"should return 404 Not found");
}

#pragma mark - HYBBridgeDelegate

- (NSArray *)bridgeActions:(HYBBridge *)bridge {
    return @[@"test", @"do_something"];
}

#pragma mark - HYBBridgeDelegate

- (NSDictionary *)bridgeCustomData:(HYBBridge *)bridge {
    return @{@"test": @{@"foo": @"bar"}};
}

- (NSDictionary *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    XCTAssertTrue([NSThread isMainThread], @"should be called in the main thread");
    XCTAssertEqualObjects(@"test", action, @"should receive a 'test' action");
    
    NSDictionary *expectedData = @{@"foo": @"bar"};
    XCTAssertEqualObjects(expectedData, data, @"should receive the correct data");
    
    self.didReceiveActionCalled = YES;
    
    return @{@"result": @1};
}

- (NSDictionary *)handleDoSomethingWithData:(NSDictionary *)data {
    XCTAssertTrue([NSThread isMainThread], @"should be called in the main thread");
    
    NSDictionary *expectedData = @{@"bar": @"foo"};
    XCTAssertEqualObjects(expectedData, data, @"should receive the correct data");
    
    self.handlerCalled = YES;
    
    return @{@"result": @2};
}

@end
