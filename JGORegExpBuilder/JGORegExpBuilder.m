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
@property(assign, nonatomic) NSUInteger min;
@property(assign, nonatomic) NSUInteger max;
@property(strong, nonatomic) NSRegularExpressionOptions modifiers;

@property(readonly, nonatomic) JGORegExpBuilder *(^add)(NSString *value);

@end

@implementation JGORegExpBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        _prefixes = @"";
        _suffixes = @"";
    }
    return self;
}

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
    return self.max(1).of(maybe);
}

- (JGORegExpBuilder *(^)(NSUInteger))min {
    return ^JGORegExpBuilder *(NSUInteger min) {
        self.min = min;
        return self;
    };
}

- (JGORegExpBuilder *(^)(NSUInteger))max {
    return ^JGORegExpBuilder *(NSUInteger max) {
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

- (JGORegExpBuilder *(^)(NSArray *))from {
    return ^JGORegExpBuilder *(NSArray *from) {
        self.from = [self sanitize:[some componentsJoinedByString:@""]];
        return self;
    };
}

- (JGORegExpBuilder *(^)())ignoreCase {
    return ^JGORegExpBuilder *() {
        return self.addModifier('i');
    };
}

#pragma mark - Private

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

- (JGORegExpBuilder *(^)(unichar))addModifier {
    return ^JGORegExpBuilder *(unichar modifier) {
        switch (modifier) {
            case 'i':
                self.modifiers |= NSRegularExpressionCaseInsensitive;
                break;
            default:
                break;
        }

        return self;
    };
}

- (JGORegExpBuilder *(^)(unichar))removeModifier {
    return ^JGORegExpBuilder *(unichar modifier) {
        switch (modifier) {
            case 'i':
                self.modifiers ^= NSRegularExpressionCaseInsensitive;
                break;
            default:
                break;
        }

        return self;
    };
}

@end
