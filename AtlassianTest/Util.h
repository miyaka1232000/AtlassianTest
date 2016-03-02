//
//  NSStringUtil.h
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright © 2016 Carmelita Mendoza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject
/**
 *  Method that checks if alpha numeric or not
 */
+ (BOOL) isAlphaNumeric:(NSString*)str;
+(NSString*) sanitizeString:(NSString*) str;

@end
