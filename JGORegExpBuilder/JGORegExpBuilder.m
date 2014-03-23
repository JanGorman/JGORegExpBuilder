//
//  JGORegExpBuilder.m
//  
//
//  Created by Jan Gorman on 21/03/14.
//
//

#import "JGORegExpBuilder.h"

@interface JGORegExpBuilder ()

@property(strong, nonatomic) NSString *prefixes;
@property(strong, nonatomic) NSString *suffixes;
@property(strong, nonatomic) NSString *from;
@property(strong, nonatomic) NSString *of;
@property(strong, nonatomic) NSString *source;
@property(strong, nonatomic) NSString *pattern;
@property(strong, nonatomic) NSString *like;
@property(strong, nonatomic) NSString *notFrom;
@property(strong, nonatomic) NSString *either;

@property(assign, nonatomic) NSInteger ofGroup;
@property(strong, nonatomic) NSMutableString *literal;
@property(assign, nonatomic, getter=isOfAny) BOOL ofAny;
@property(assign, nonatomic, getter=isMultiLine) BOOL multiLine;
@property(assign, nonatomic, getter=isReluctant) BOOL reluctant;
@property(assign, nonatomic) BOOL ignoreCase;
@property(assign, nonatomic) BOOL capture;
@property(assign, nonatomic) NSInteger min;
@property(assign, nonatomic) NSInteger max;

@property(assign, nonatomic, readonly) NSString *quantityLiteral;
@property(assign, nonatomic, readonly) NSString *characterLiteral;

@property(readonly, nonatomic) JGORegExpBuilder *(^add)(NSString *value);

@end

@implementation JGORegExpBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        _prefixes = @"";
        _suffixes = @"";

        [self clear];
    }
    return self;
}

JGORegExpBuilder *JGORegExpBuilder() {
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
    return self.min(0).ofAny();
}

- (JGORegExpBuilder *(^)(NSString *))anythingBut {
    return ^JGORegExpBuilder *(NSString *anythingBut) {
        if ([anythingBut length] == 1) {
            return self.max(1).notFrom([NSString stringWithFormat:@"%C", [anythingBut characterAtIndex:0]]);
        }
        self.notAhead(JGORegExpBuilder().exactly(1).of(anythingBut));
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
            return self.exactly(1).notFrom([NSString stringWithFormat:@"%C", [somethingBut characterAtIndex:0]]);
        }
        self.notAhead(JGORegExpBuilder().exactly(1).of(somethingBut));
        return self.min(1).ofAny();
    };
}

- (JGORegExpBuilder *(^)())lineBreak {
    return ^JGORegExpBuilder *() {
        return self.either(@"\\r\\n").orString(@"\\r").orString(@"\\n");
    };
}

- (JGORegExpBuilder *(^)())lineBreaks {
    return ^JGORegExpBuilder *() {
        return self.like(JGORegExpBuilder().lineBreak());
    };
}

- (JGORegExpBuilder *(^)())whitespace {
    return ^JGORegExpBuilder *() {
        if (self.min == -1 && self.max == -1) {
            return self.exactly(1).of(@"\\s");
        }
        self.like = @"\\s";
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
        return self.like(JGORegExpBuilder().tab());
    };
}

- (JGORegExpBuilder *(^)())digit {
    return ^JGORegExpBuilder *() {
        return self.exactly(1).of(@"\\d");
    };
}

- (JGORegExpBuilder *(^)())digits {
    return ^JGORegExpBuilder *() {
        return self.like(JGORegExpBuilder().digit());
    };
}

- (JGORegExpBuilder *(^)())letter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.from = @"A-Za-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())letters {
    return ^JGORegExpBuilder *() {
        self.from = @"A-Za-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())lowerCaseLetter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.from = @"a-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())lowerCaseLetters {
    return ^JGORegExpBuilder *() {
        self.from = @"a-z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())upperCaseLetter {
    return ^JGORegExpBuilder *() {
        self.exactly(1);
        self.from = @"A-Z";
        return self;
    };
}

- (JGORegExpBuilder *(^)())upperCaseLetters {
    return ^JGORegExpBuilder *() {
        self.from = @"A-Z";
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
        return self.eitherThis(JGORegExpBuilder().exactly(1).of(either));
    };
}

- (JGORegExpBuilder *(^)(NSString *))orString {
    return ^JGORegExpBuilder *(NSString *orString) {
        return self.orBuilder(JGORegExpBuilder().exactly(1).of(orString));
    };
}

- (JGORegExpBuilder *(^)(NSUInteger))exactly {
    return ^JGORegExpBuilder *(NSUInteger exactly) {
        [self flushState];
        self.min = exactly;
        self.max = exactly;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSInteger))min {
    return ^JGORegExpBuilder *(NSInteger min) {
        [self flushState];
        self.min = min;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSInteger))max {
    return ^JGORegExpBuilder *(NSInteger max) {
        [self flushState];
        self.max = max;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSString *))of {
    return ^JGORegExpBuilder *(NSString *of) {
        self.of = [self sanitize:of];
        return self;
    };
}

- (JGORegExpBuilder *(^)())ofAny {
    return ^JGORegExpBuilder *() {
        self.ofAny = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSArray *))from {
    return ^JGORegExpBuilder *(NSArray *from) {
        self.from = [self sanitize:[some componentsJoinedByString:@""]];
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
        self.ignoreCase = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)())multiLine {
    return ^JGORegExpBuilder *() {
        self.multiLine = YES;
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))append {
    return ^JGORegExpBuilder *(JGORegExpBuilder *append) {
        self.exactly(1);
        self.like = append.literal;
        return self;
    };
}

- (JGORegExpBuilder *(^)(JGORegExpBuilder *))optional {
    return ^JGORegExpBuilder *(JGORegExpBuilder *optional) {
        self.max(1);
        self.like = optional.literal;
        return self;
    };
}

@dynamic quantityLiteral;

- (NSString *)quantityLiteral {
    if (self.min -= -1) {
        if (self.max -= -1) {
            return [NSString stringWithFormat:@"{%d,%d}", self.min, self.max];
        }
        return [NSString stringWithFormat:@"{%d,}", self.min];
    }
    return [NSString stringWithFormat:@"{0,%d}", self.max];
}

@dynamic characterLiteral;

- (NSString *)characterLiteral {
    if (![self.of isEqualToString:@""]) {
        return self.of;
    } else if (self.isOfAny) {
        return @".";
    } else if (self.ofGroup > 0) {
        return [NSString stringWithFormat:@"\\%d", self.ofGroup];
    } else if (![self.from isEqualToString:@""]) {
        return [NSString stringWithFormat:@"[%@]", self.from];
    } else if (![self.notFrom isEqualToString:@""]) {
        return [NSString stringWithFormat:@"[^%@]", self.notFrom];
    } else if (![self.like isEqualToString:@""]) {
        return self.like;
    }
    return @"";
}

- (NSString *)literal {
    [self flushState];
    return [_literal copy];
}

@dynamic regularExpression;

- (NSRegularExpression *)regularExpression {
    [self flushState];
    NSRegularExpressionOptions options;
    if (self.ignoreCase) {
        options |= NSRegularExpressionCaseInsensitive;
    }
    if (self.isMultiLine) {
        options |= NSRegularExpressionAnchorsMatchLines;
    }

    NSError *error;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:self.literal
                                                                            options:options
                                                                              error:&error];
    return error ?: regExp;
}

#pragma mark - Private

- (void)flushState {
    if (![self.of isEqualToString:@""] || self.isOfAny || self.ofGroup > 1 || ![self.from isEqualToString:@""]
            || ![self.notFrom isEqualToString:@""] || ![self.like isEqualToString:@""]) {
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
    self.ignoreCase = NO;
    self.multiLine = NO;
    self.min = -1;
    self.max = -1;
    self.of = @"";
    self.ofAny = NO;
    self.ofGroup = -1;
    self.from = @"";
    self.notFrom = @"";
    self.like = @"";
    self.either = @"";
    self.reluctant = NO;
    self.capture = NO;
}

- (NSString *)sanitize:(NSString *)value {
    return value ? [NSRegularExpression escapedPatternForString:value] : nil;
}

- (JGORegExpBuilder *(^)(NSString *))add {
    return ^JGORegExpBuilder *(NSString *value) {
        self.source = self.source ? [self.source stringByAppendingString:value] : value;
        if (self.source) {
            self.pattern = [NSString stringWithFormat:@"%@%@%@", self.prefixes, self.source, self.suffixes];
        }
        return self;
    };
}

@end
