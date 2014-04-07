//
//  HYBBridgeTests.m
//  Hybridge
//
//  Created by guille on 04/04/14.
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
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
    XCTAssertEqual((NSInteger)1, [HYBBridge version], @"should return the right version");
}

- (void)testActiveBridge {
    HYBBridge *bridge = [HYBBridge new];
    [HYBBridge setActiveBridge:bridge];
    
    XCTAssertEqualObjects(bridge, [HYBBridge activeBridge], @"should return the active bridge");
}

- (void)testPrepareWebView {
    id webView = [self autoVerifiedMockForClass:[UIWebView class]];
    
    NSString *javascript = @"window.HybridgeGlobal || setTimeout(function() {"
                           @"	window.HybridgeGlobal = {"
                           @"		isReady:true,"
                           @"		version:1,"
                           @"		actions:[\"test\",\"something\"],"
                           @"		events:[\"pause\",\"resume\",\"message\",\"ready\"]"
                           @"	};"
                           @"	window.$ && $('#hybridgeTrigger').toggleClass('switch');"
                           @"}, 0)";
    
    [[[webView expect] andReturn:@"ok"] stringByEvaluatingJavaScriptFromString:javascript];
    
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;
    
    NSString *result = [bridge prepareWebView:webView];
    XCTAssertEqualObjects(@"ok", result, @"should return the value returned by the web view");
}

- (void)testActionDispatch {
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;
    
    [HYBBridge setActiveBridge:bridge];
    
    NSURL *url = [NSURL URLWithString:@"http://hybridge/test"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"{\"foo\":\"bar\"}" forHTTPHeaderField:@"data"];
    
    NSHTTPURLResponse * __block response = nil;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *data, NSError *error) {
                               response = (NSHTTPURLResponse *)r;
                           }];
    HYBAssertEventually(response, @"should complete with a response");
    
    XCTAssertTrue(self.didReceiveActionCalled, @"should call the delegate");
    XCTAssertEqual((NSInteger)200, [response statusCode], @"should return 200 OK");
}

- (void)testActionDispatchWithMethodHandler {
    HYBBridge *bridge = [HYBBridge new];
    bridge.delegate = self;
    
    [HYBBridge setActiveBridge:bridge];
    
    NSURL *url = [NSURL URLWithString:@"http://hybridge/something"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"{\"bar\":\"foo\"}" forHTTPHeaderField:@"data"];
    
    NSHTTPURLResponse * __block response = nil;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *data, NSError *error) {
                               response = (NSHTTPURLResponse *)r;
                           }];
    HYBAssertEventually(response, @"should complete with a response");
    
    XCTAssertTrue(self.handlerCalled, @"should call the handler method");
    XCTAssertEqual((NSInteger)200, [response statusCode], @"should return 200 OK");
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
    return @[@"test", @"something"];
}

- (NSHTTPURLResponse *)bridgeDidReceiveAction:(NSString *)action data:(NSDictionary *)data {
    XCTAssertTrue([NSThread isMainThread], @"should be called in the main thread");
    XCTAssertEqualObjects(@"test", action, @"should receive a 'test' action");
    
    NSDictionary *expectedData = @{@"foo": @"bar"};
    XCTAssertEqualObjects(expectedData, data, @"should receive the correct data");
    
    self.didReceiveActionCalled = YES;
    return nil;
}

- (void)handleSomethingWithData:(NSDictionary *)data {
    XCTAssertTrue([NSThread isMainThread], @"should be called in the main thread");
    
    NSDictionary *expectedData = @{@"bar": @"foo"};
    XCTAssertEqualObjects(expectedData, data, @"should receive the correct data");
    
    self.handlerCalled = YES;
}

@end
