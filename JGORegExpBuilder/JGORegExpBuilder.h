//
//  JGORegExpBuilder.h
//  
//
//  Created by Jan Gorman on 21/03/14.
//
//

#import <Foundation/Foundation.h>

@interface JGORegExpBuilder : NSObject

@property(nonatomic, readonly) JGORegExpBuilder *(^ignoreCase)(BOOL enable);

@end
