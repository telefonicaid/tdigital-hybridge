//
//  HYBTestCase.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Hybridge/Hybridge.h>

@interface HYBTestCase : XCTestCase

// Calls +[OCMockObject mockForClass:] and adds the mock and call -verify on it during -tearDown.
- (id)autoVerifiedMockForClass:(Class)aClass;

// Calls +[OCMockObject partialMockForClass:] and adds the mock and call -verify on it during -tearDown.
- (id)autoVerifiedPartialMockForObject:(id)object;

// Calls -verify on the mock during -tearDown.
- (void)verifyDuringTearDown:(id)mock;

@end
