//
//  DemoTests.m
//  DemoTests
//
//  Created by Jan Gorman on 23/03/14.
//  Copyright (c) 2014 Jan Gorman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JGORegExpBuilder.h"

@interface DemoTests : XCTestCase

@end

@implementation DemoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testStartOfLine {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(1).of(@"p");

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertFalse(builder.test(@"qp"));
}

@end
