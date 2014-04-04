//
//  HYBTestCase.m
//  Hybridge
//
//  Created by guille on 04/04/14.
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//

#import "HYBTestCase.h"

@interface HYBTestCase ()

@property (strong, nonatomic) NSMutableArray *mocksToVerify;

@end

@implementation HYBTestCase

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    for (id mock in self.mocksToVerify) {
        [mock verify];
    }
    self.mocksToVerify = nil;
    [super tearDown];
}

- (id)autoVerifiedMockForClass:(Class)aClass {
    id mock = [OCMockObject mockForClass:aClass];
    [self verifyDuringTearDown:mock];
    return mock;
}

- (id)autoVerifiedPartialMockForObject:(id)object {
    id mock = [OCMockObject partialMockForObject:object];
    [self verifyDuringTearDown:mock];
    return mock;
}

- (void)verifyDuringTearDown:(id)mock {
    if (self.mocksToVerify == nil) {
        self.mocksToVerify = [NSMutableArray array];
    }
    [self.mocksToVerify addObject:mock];
}

@end
