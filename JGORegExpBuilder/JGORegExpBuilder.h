//
//  JGORegExpBuilder.h
//  
//
//  Created by Jan Gorman on 21/03/14.
//
//

#import <Foundation/Foundation.h>

@interface JGORegExpBuilder : NSObject

@property(nonatomic, readonly) JGORegExpBuilder *(^then)(NSString *then);
@property(nonatomic, readonly) JGORegExpBuilder *(^some)(NSArray *some);
@property(nonatomic, readonly) JGORegExpBuilder *(^maybeSome)(NSArray *maybeSome);
@property(nonatomic, readonly) JGORegExpBuilder *(^maybe)(NSString *maybe);
@property(nonatomic, readonly) JGORegExpBuilder *(^anything)();
@property(nonatomic, readonly) JGORegExpBuilder *(^anythingBut)(NSString *anythingBut);
@property(nonatomic, readonly) JGORegExpBuilder *(^something)();
@property(nonatomic, readonly) JGORegExpBuilder *(^somethingBut)(NSString *somethingBut);
@property(nonatomic, readonly) JGORegExpBuilder *(^lineBreak)();
@property(nonatomic, readonly) JGORegExpBuilder *(^lineBreaks)();
@property(nonatomic, readonly) JGORegExpBuilder *(^whitespace)();
@property(nonatomic, readonly) JGORegExpBuilder *(^tab)();
@property(nonatomic, readonly) JGORegExpBuilder *(^tabs)();
@property(nonatomic, readonly) JGORegExpBuilder *(^digit)();
@property(nonatomic, readonly) JGORegExpBuilder *(^digits)();
@property(nonatomic, readonly) JGORegExpBuilder *(^letter)();
@property(nonatomic, readonly) JGORegExpBuilder *(^letters)();
@property(nonatomic, readonly) JGORegExpBuilder *(^lowerCaseLetter)();
@property(nonatomic, readonly) JGORegExpBuilder *(^lowerCaseLetters)();
@property(nonatomic, readonly) JGORegExpBuilder *(^upperCaseLetter)();
@property(nonatomic, readonly) JGORegExpBuilder *(^upperCaseLetters)();
@property(nonatomic, readonly) JGORegExpBuilder *(^startOfInput)();
@property(nonatomic, readonly) JGORegExpBuilder *(^startOfLine)();
@property(nonatomic, readonly) JGORegExpBuilder *(^endOfInput)();
@property(nonatomic, readonly) JGORegExpBuilder *(^endOfLine)();
@property(nonatomic, readonly) JGORegExpBuilder *(^eitherThis)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^orBuilder)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^either)(NSString *either);
@property(nonatomic, readonly) JGORegExpBuilder *(^orString)(NSString *orThat);
@property(nonatomic, readonly) JGORegExpBuilder *(^neither)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^nor)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^neither)(NSString *neither);
@property(nonatomic, readonly) JGORegExpBuilder *(^nor)(NSString *nor);
@property(nonatomic, readonly) JGORegExpBuilder *(^exactly)(NSUInteger exactly);
@property(nonatomic, readonly) JGORegExpBuilder *(^min)(NSUInteger exactly);
@property(nonatomic, readonly) JGORegExpBuilder *(^max)(NSUInteger exactly);
@property(nonatomic, readonly) JGORegExpBuilder *(^of)(NSString *of);
@property(nonatomic, readonly) JGORegExpBuilder *(^ofAny)();
@property(nonatomic, readonly) JGORegExpBuilder *(^ofGroup)(NSUInteger group);
@property(nonatomic, readonly) JGORegExpBuilder *(^from)(NSArray *from);
@property(nonatomic, readonly) JGORegExpBuilder *(^notFrom)(NSArray *from);
@property(nonatomic, readonly) JGORegExpBuilder *(^like)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^reluctantly)();
@property(nonatomic, readonly) JGORegExpBuilder *(^ahead)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^notAhead)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^asGroup)();

@property(nonatomic, readonly) JGORegExpBuilder *(^ignoreCase)();
@property(nonatomic, readonly) JGORegExpBuilder *(^multiLine)();
@property(nonatomic, readonly) JGORegExpBuilder *(^append)(JGORegExpBuilder *regExpBuilder);
@property(nonatomic, readonly) JGORegExpBuilder *(^optional)(JGORegExpBuilder *regExpBuilder);

extern JGORegExpBuilder *JGORegExpBuilder();

@end
