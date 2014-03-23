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

- (void)testEndOfLine {
    JGORegExpBuilder *builder = RegExpBuilder().exactly(1).of(@"p").endOfLine();

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertTrue(builder.test(@"qp"));
    XCTAssertFalse(builder.test(@"qpq"));
}

- (void)testEitherOr {
    JGORegExpBuilder *firstBuilder = RegExpBuilder().exactly(1).of(@"p");
    JGORegExpBuilder *secondBuilder = RegExpBuilder().exactly(2).of(@"q");

    JGORegExpBuilder *builder = RegExpBuilder()
            .startOfLine()
            .eitherBuilder(firstBuilder)
            .orBuilder(secondBuilder)
            .endOfLine();

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertTrue(builder.test(@"qq"));
    XCTAssertFalse(builder.test(@"pqq"));
    XCTAssertFalse(builder.test(@"qqp"));
}

- (void)testOrChain {
    JGORegExpBuilder *firstBuilder = RegExpBuilder().exactly(1).of(@"p");
    JGORegExpBuilder *secondBuilder = RegExpBuilder().exactly(1).of(@"q");
    JGORegExpBuilder *thirdBuilder = RegExpBuilder().exactly(1).of(@"r");

    JGORegExpBuilder *builder = RegExpBuilder()
            .eitherBuilder(firstBuilder)
            .orBuilder(secondBuilder)
            .orBuilder(thirdBuilder);

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertTrue(builder.test(@"q"));
    XCTAssertTrue(builder.test(@"r"));
    XCTAssertFalse(builder.test(@"s"));
}

- (void)testOrString {
    JGORegExpBuilder *builder = RegExpBuilder().eitherString(@"p").orString(@"q");

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertTrue(builder.test(@"q"));
    XCTAssertFalse(builder.test(@"r"));
}

- (void)testExactly {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(3).of(@"p").endOfLine();

    XCTAssertTrue(builder.test(@"ppp"));
    XCTAssertFalse(builder.test(@"pp"));
    XCTAssertFalse(builder.test(@"pppp"));
}

- (void)testMin {

}

@end
