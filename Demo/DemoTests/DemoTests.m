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
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().min(2).of(@"p").endOfLine();

    XCTAssertTrue(builder.test(@"pp"));
    XCTAssertTrue(builder.test(@"ppp"));
    XCTAssertTrue(builder.test(@"ppppppp"));
    XCTAssertFalse(builder.test(@"p"));
}

- (void)testMax {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().max(3).of(@"p").endOfLine();

    XCTAssertTrue(builder.test(@"p"));
    XCTAssertTrue(builder.test(@"pp"));
    XCTAssertTrue(builder.test(@"ppp"));
    XCTAssertFalse(builder.test(@"ppppppp"));
}

- (void)testMinMax {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().min(3).max(7).of(@"p").endOfLine();

    XCTAssertTrue(builder.test(@"ppp"));
    XCTAssertTrue(builder.test(@"ppppp"));
    XCTAssertTrue(builder.test(@"ppppppp"));
    XCTAssertFalse(builder.test(@"pppppppppp"));
    XCTAssertFalse(builder.test(@"p"));
    XCTAssertFalse(builder.test(@"pp"));
}

- (void)testOf {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(2).of(@"p p p ").endOfLine();

    XCTAssertTrue(builder.test(@"p p p p p p "));
    XCTAssertFalse(builder.test(@"p p p p p pp"));
}

- (void)testOfAny {
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(3).ofAny().endOfLine();

    XCTAssertTrue(builder.test(@"abc"));
    XCTAssertFalse(builder.test(@"abcd"));
}

- (void)testOfGroup {
    JGORegExpBuilder *builder = RegExpBuilder()
            .startOfLine()
            .exactly(3).of(@"p").asGroup()
            .exactly(1).of(@"q")
            .exactly(1).ofGroup(1);

    XCTAssertTrue(builder.test(@"pppqppp"));
}

- (void)testFrom {
    NSArray *letters = @[@"p", @"q", @"r"];
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(3).from(letters).endOfLine();

    XCTAssertTrue(builder.test(@"ppp"));
    XCTAssertTrue(builder.test(@"qqq"));
    XCTAssertTrue(builder.test(@"rrr"));
    XCTAssertTrue(builder.test(@"pqr"));
    XCTAssertFalse(builder.test(@"pyy"));
}

- (void)testNotFrom {
    NSArray *letters = @[@"p", @"q", @"r"];
    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(3).notFrom(letters).endOfLine();

    XCTAssertTrue(builder.test(@"lmn"));
    XCTAssertFalse(builder.test(@"lmq"));
}

@end
