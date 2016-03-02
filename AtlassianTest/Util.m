//
//  NSStringUtil.m
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright © 2016 Carmelita Mendoza. All rights reserved.
//

#import "Util.h"

@implementation Util

+(BOOL) isAlphaNumeric:(NSString*)str
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([str rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

+(NSString*) sanitizeString:(NSString*) jsonString
{
    NSUInteger len = [jsonString length];
  
    
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:(len-2)];
    NSUInteger limit = len - 1;
    for (NSUInteger i = 1; i < limit; ++i) {
        unichar character = [jsonString characterAtIndex:i];
        
        if (character == '\\') {
            
            // Escape sequence
            
            if (i == limit - 1) {
                NSLog(@"%s: JSON string cannot end with single backslash", __PRETTY_FUNCTION__);
                return nil;
            }
            
            ++i;
            unichar nextCharacter = [jsonString characterAtIndex:i];
            switch (nextCharacter) {
                case 'b':
                    [result appendString:@"\b"];
                    break;
                    
                case 'f':
                    [result appendString:@"\f"];
                    break;
                    
                case 'n':
                    [result appendString:@"\n"];
                    break;
                    
                case 'r':
                    [result appendString:@"\r"];
                    break;
                    
                case 't':
                    [result appendString:@"\t"];
                    break;
                    
                case 'u':
                    if ((i + 4) >= limit) {
                        NSLog(@"%s: insufficient characters remaining after \\u in JSON string", __PRETTY_FUNCTION__);
                        return nil;
                    }
                {
                    NSString *hexdigits = [jsonString substringWithRange:NSMakeRange(i + 1, 4)];
                    i += 4;
                    NSScanner *scanner = [NSScanner scannerWithString:hexdigits];
                    unsigned int hexValue = 0;
                    if (![scanner scanHexInt:&hexValue]) {
                        NSLog(@"%s: invalid hex digits following \\u", __PRETTY_FUNCTION__);
                    }
                    [result appendFormat:@"%C", (unichar)hexValue];
                }
                    break;
                    
                default:
                    [result appendFormat:@"%C", nextCharacter];
                    break;
            }
        }
        else {
            // No escape
            [result appendFormat:@"%C", character];
        }
    }
    
    NSString * output = [NSString stringWithString:result];
    output = [output stringByReplacingOccurrencesOfString:@"&amp;"   withString:@"&"];
    output = [output  stringByReplacingOccurrencesOfString:@"&quot;" withString: @"\"" ];
    output=  [output stringByReplacingOccurrencesOfString:@"&#39;"   withString: @"'"];
    output=  [output stringByReplacingOccurrencesOfString:@"&gt;"    withString: @">"];
    output=  [output stringByReplacingOccurrencesOfString:@"&lt;"    withString:@"<" ];
    return output;

}

@end
