//
//  JGORegExpBuilder.m
//  
//
//  Created by Jan Gorman on 21/03/14.
//
//

#import "JGORegExpBuilder.h"

@interface JGORegExpBuilder ()

@property(strong, nonatomic) NSString *fromValue;
@property(strong, nonatomic) NSString *ofValue;
@property(strong, nonatomic) NSString *likeValue;
@property(strong, nonatomic) NSString *notFromValue;
@property(strong, nonatomic) NSString *either;

@property(assign, nonatomic) NSInteger ofGroupValue;
@property(strong, nonatomic) NSMutableString *literal;
@property(assign, nonatomic, getter=isOfAnyValue) BOOL ofAnyValue;
@property(assign, nonatomic, getter=isMultiLineValue) BOOL multiLineValue;
@property(assign, nonatomic, getter=isReluctant) BOOL reluctant;
@property(assign, nonatomic) BOOL ignoreCaseValue;
@property(assign, nonatomic) BOOL capture;
@property(assign, nonatomic) NSInteger minValue;
@property(assign, nonatomic) NSInteger maxValue;

@property(assign, nonatomic, readonly) NSString *quantityLiteral;
@property(assign, nonatomic, readonly) NSString *characterLiteral;

@property(readonly, nonatomic) JGORegExpBuilder *(^add)(NSString *value);

@end

@implementation JGORegExpBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        [self clear];
    }
    return self;
}

JGORegExpBuilder *RegExpBuilder() {
    return [[JGORegExpBuilder alloc] init];
};

#pragma mark - Custom Accessors

- (JGORegExpBuilder *(^)(NSString *))then {
    return ^JGORegExpBuilder *(NSString *then) {
        return self.add([NSString stringWithFormat:@"(?:%@)", [self sanitize:then]]);
    };
}

- (JGORegExpBuilder *(^)(NSArray *))some {
    return ^JGORegExpBuilder *(NSArray *some) {
        return self.min(1).from(some);
    };
}

- (JGORegExpBuilder *(^)(NSArray *))maybeSome {
    return ^JGORegExpBuilder *(NSArray *maybeSome) {
        return self.min(0).from(maybeSome);
    };
}

- (JGORegExpBuilder *(^)(NSString *))maybe {
    return ^JGORegExpBuilder *(NSString *maybe) {
        return self.max(1).of(maybe);
    };
}

- (JGORegExpBuilder *(^)())anything {
    return ^JGORegExpBuilder *() {
        return self.min(0).ofAny();
    };
}

- (JGORegExpBuilder *(^)(NSString *))anythingBut {
    return ^JGORegExpBuilder *(NSString *anythingBut) {
        if ([anythingBut length] == 1) {
            return self.max(1).notFrom(@[[anythingBut substringToIndex:1]]);
        }
        self.notAhead(RegExpBuilder().exactly(1).of(anythingBut));
        return self.min(0).ofAny();
    };
}

- (JGORegExpBuilder *(^)())something {
    return ^JGORegExpBuilder *() {
        return self.min(1).ofAny();
    };
}

- (JGORegExpBuilder *(^)(NSString *))somethingBut {
    return ^JGORegExpBuilder *(NSString *somethingBut) {
        if ([somethingBut length] == 1) {
            return self.exactly(1).notFrom(@[[somethingBut substringToIndex:1]]);
        }
        self.notAhead(RegExpBuilder().exactly(1).of(somethingBut));
        return self.min(1).ofAny();
    };
}

- (JGORegExpBuilder *(^)())lineBreak {
    return ^JGORegExpBuilder *() {
        return self.eitherString(@"\\r\\n").orString(@"\\r").orString(@"\\n");
    };
}

- (JGORegExpBuilder *(^)())lineBreaks {
    return ^JGORegExpBuilder *() {
        return self.like(RegExpBuilder().lineBreak());
    };
}

- (JGORegExpBuilder *(^)())whitespace {
    return ^JGORegExpBuilder *() {
        if (self.minValue == -1 && self.maxValue == -1) {
            return self.exactly(1).of(@"\\s");
        }
        self.likeValue = @"\\s";
        return self;
    };
}

- (JGORegExpBuilder *(^)())tab {
    return ^JGORegExpBuilder *() {
        return self.exactly(1).of(@"\\t");
    };
}

- (JGORegExpBuilder *(^)())tabs {
    return ^JGORegExpBuilder *() {
        return self.like(RegExpBuilder().tab());
    };
}

- (JGORegExpBuilder *(^)())digit {
    return ^JGORegExpBuilder *() {
        return self.exactly(1).of(@"\\d");
    };
}

- (JGORegExpBuilder *(^)())digits {
    return ^JGORegExpBuilder *() {
        return self.like(RegExpBuilder().digit());
    };
}

- (JGORegExpBuilder *(^)())letter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.fromValue = @"A-Za-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())letters {
    return ^JGORegExpBuilder *() {
        self.fromValue = @"A-Za-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())lowerCaseLetter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.fromValue = @"a-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())lowerCaseLetters {
    return ^JGORegExpBuilder *() {
        self.fromValue = @"a-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())upperCaseLetter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.fromValue = @"A-Z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())upperCaseLetters {
    return ^JGORegExpBuilder *() {
        self.fromValue = @"A-Z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())startOfInput {
    return ^JGORegExpBuilder *() {
        [self.literal appendString:@"(?:^)"];
        return self;
    };
}

- (JGORegExpBuilder *(^)())startOfLine {
    return ^JGORegExpBuilder *() {
        self.multiLine();
        return self.startOfLine();
    };
}

- (JGORegExpBuilder *(^)())endOfInput {
    return ^JGORegExpBuilder *() {
        [self flushState];
        [self.literal appendString:@"(?:$)"];
        return self;
    };
}

- (JGORegExpBuilder *(^)())endOfLine {
    return ^JGORegExpBuilder *() {
        self.multiLine();
        return self.endOfInput();
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))eitherBuilder {
    return ^JGORegExpBuilder *(JGORegExpBuilder *regExpBuilder) {
        [self flushState];
        self.either = regExpBuilder.literal;
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))orBuilder {
    return ^JGORegExpBuilder *(JGORegExpBuilder *regExpBuilder) {
        NSString *either = self.either;
        NSString *or = regExpBuilder.literal;

        if ([either isEqualToString:@""]) {
            [self.literal deleteCharactersInRange:NSMakeRange([self.literal length] - 1, 1)];
            [self.literal appendFormat:@"|(?:%@))", or];
        } else {
            [self.literal appendFormat:@"(?:(?:%@)|(?:%@))", either, or];
        }
        [self clear];
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSString *))eitherString {
    return ^JGORegExpBuilder *(NSString *either) {
        return self.eitherBuilder(RegExpBuilder().exactly(1).of(either));
    };
}

- (JGORegExpBuilder *(^)(NSString *))orString {
    return ^JGORegExpBuilder *(NSString *orString) {
        return self.orBuilder(RegExpBuilder().exactly(1).of(orString));
    };
}

- (JGORegExpBuilder *(^)(NSUInteger))exactly {
    return ^JGORegExpBuilder *(NSUInteger exactly) {
        [self flushState];
        self.minValue = exactly;
        self.maxValue = exactly;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSUInteger))min {
    return ^JGORegExpBuilder *(NSUInteger min) {
        [self flushState];
        self.minValue = min;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSUInteger))max {
    return ^JGORegExpBuilder *(NSUInteger max) {
        [self flushState];
        self.maxValue = max;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSString *))of {
    return ^JGORegExpBuilder *(NSString *of) {
        self.ofValue = [self sanitize:of];
        return self;
    };
}

- (JGORegExpBuilder *(^)())ofAny {
    return ^JGORegExpBuilder *() {
        self.ofAnyValue = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSArray *))from {
    return ^JGORegExpBuilder *(NSArray *from) {
        self.fromValue = [self sanitize:[from componentsJoinedByString:@""]];
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))ahead {
    return ^JGORegExpBuilder *(JGORegExpBuilder *ahead) {
        [self flushState];
        [self.literal stringByAppendingFormat:@"(?=%@)", ahead.literal];
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))notAhead {
    return ^JGORegExpBuilder *(JGORegExpBuilder *notAhead) {
        [self flushState];
        [self.literal appendString:[NSString stringWithFormat:@"?!%@)", notAhead.literal]];
        return self;
    };
}

- (JGORegExpBuilder *(^)())asGroup {
    return ^JGORegExpBuilder *() {
        self.capture = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)())ignoreCase {
    return ^JGORegExpBuilder *() {
        self.ignoreCaseValue = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)())multiLine {
    return ^JGORegExpBuilder *() {
        self.multiLineValue = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))append {
    return ^JGORegExpBuilder *(JGORegExpBuilder *append) {
        self.exactly(1);
        self.likeValue = append.literal;
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))optional {
    return ^JGORegExpBuilder *(JGORegExpBuilder *optional) {
        self.max(1);
        self.likeValue = optional.literal;
        return self;
    };
}

@dynamic quantityLiteral;

- (NSString *)quantityLiteral {
    if (self.minValue -= -1) {
        if (self.maxValue -= -1) {
            return [NSString stringWithFormat:@"{%d,%d}", self.minValue, self.maxValue];
        }
        return [NSString stringWithFormat:@"{%d,}", self.minValue];
    }
    return [NSString stringWithFormat:@"{0,%d}", self.maxValue];
}

@dynamic characterLiteral;

- (NSString *)characterLiteral {
    if (![self.ofValue isEqualToString:@""]) {
        return self.ofValue;
    } else if (self.isOfAnyValue) {
        return @".";
    } else if (self.ofGroupValue > 0) {
        return [NSString stringWithFormat:@"\\%d", self.ofGroupValue];
    } else if (![self.fromValue isEqualToString:@""]) {
        return [NSString stringWithFormat:@"[%@]", self.fromValue];
    } else if (![self.notFromValue isEqualToString:@""]) {
        return [NSString stringWithFormat:@"[^%@]", self.notFromValue];
    } else if (![self.likeValue isEqualToString:@""]) {
        return self.likeValue;
    }
    return @"";
}

- (NSMutableString *)literal {
    [self flushState];
    return [_literal copy];
}

@dynamic regularExpression;

- (NSRegularExpression *)regularExpression {
    [self flushState];
    NSRegularExpressionOptions options = 0;
    if (self.ignoreCaseValue) {
        options |= NSRegularExpressionCaseInsensitive;
    }
    if (self.isMultiLineValue) {
        options |= NSRegularExpressionAnchorsMatchLines;
    }

    NSError *error;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:self.literal
                                                                            options:options
                                                                              error:&error];
    return error ? nil : regExp;
}

#pragma mark - Private

- (void)flushState {
    if (![self.ofValue isEqualToString:@""] || self.isOfAnyValue || self.ofGroupValue > 1
            || ![self.fromValue isEqualToString:@""]
            || ![self.notFromValue isEqualToString:@""] || ![self.likeValue isEqualToString:@""]) {
        NSString *captureLiteral = self.capture ? @"" : @"?:";
        NSString *reluctantLiteral = self.isReluctant ? @"?" : @"";
        [self.literal stringByAppendingFormat:@"(%@(?:%@)%@%@)",
                                              captureLiteral,
                                              [self characterLiteral],
                                              [self quantityLiteral],
                                              reluctantLiteral];

        [self clear];
    }
}

- (void)clear {
    self.ignoreCaseValue = NO;
    self.multiLineValue = NO;
    self.minValue = -1;
    self.maxValue = -1;
    self.ofValue = @"";
    self.ofAnyValue = NO;
    self.ofGroupValue = -1;
    self.fromValue = @"";
    self.notFromValue = @"";
    self.likeValue = @"";
    self.either = @"";
    self.reluctant = NO;
    self.capture = NO;
}

- (NSString *)sanitize:(NSString *)value {
    return value ? [NSRegularExpression escapedPatternForString:value] : nil;
}

@end
