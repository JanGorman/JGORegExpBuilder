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
@property(strong, nonatomic) NSString *source;
@property(strong, nonatomic) NSString *pattern;
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

- (JGORegExpBuilder *(^)(BOOL))ignoreCase {
    return ^JGORegExpBuilder *(BOOL enable) {
        if (enable) {
            self.addModifier('i');
        } else {
            self.removeModifier('i');
        }
        return self;
    };
}

#pragma mark - Private

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
