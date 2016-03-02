//
//  MessageManager.m
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright (c) 2016 Carmelita Mendoza. All rights reserved.
//


#import "MessageManager.h"
#import "Util.h"
#define MAX_TITLE_LEN 60


@implementation MessageManager
static NSString * MENTIONS = @"mentions";
static NSString * EMOTICONS = @"emoticons";
static NSString * LINKS = @"links";
static NSString * URL = @"url";
static NSString * TITLE = @"title";
static NSString * SPACE_PREDICATE = @"SELF != ''";
/*
 *  Mention begin with @
 */
static NSString * MENTION_PREDICATE = @"SELF BEGINSWITH %@";
/**
 * emoticons end with ( and begin with ) and with length of <=15
 */
static NSString * EMOTICON_PREDICATE =@"self BEGINSWITH[cd] %@ AND self ENDSWITH[cd] %@ AND self.length <=15";

static NSString * VALID_CHAR = @"A-Z0-9a-z";

static NSString * URL_PREDICATE = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";


/**
 * Initialization Method that return the singleton object class
 * @return MessageManager the singleton object
 */
+(MessageManager*) sharedManager{

    static dispatch_once_t predicate;
    static MessageManager *messageParser = nil;
    dispatch_once(&predicate, ^{
        messageParser = [[MessageManager alloc] init];
        
    });
    
    return messageParser;
}

/**
 * Method that parse the message to json string
 * @return messagse the message string object
 */
-(NSString*) messagetoJsonString:(NSString*)message{

    if(message ==nil || message.length <= 0){
        return nil;
    }
    
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    message = [message stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    message = [message stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    
    
    NSArray *array = [message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:SPACE_PREDICATE]];
    
    
    NSArray* mentions = [self getMentions:array];
    NSArray* emoticons = [self getEmoticons:array];
    NSArray * links = [self getLinks:array];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if(mentions!=nil && [mentions count] >0){
        [dict setValue:mentions forKey:MENTIONS];
    }
    if(emoticons!=nil && [emoticons count] > 0){
        [dict setValue:emoticons forKey:EMOTICONS];
    }
    
    if(links && [links count] >0){
        NSMutableArray * array = [[NSMutableArray alloc] init];
        
        for(NSString * url in links){
            NSString* title = [self getTitleWithURL:url];
            NSMutableDictionary * dict  = [[NSMutableDictionary alloc]initWithDictionary:@{URL:url, TITLE:title}];
            [array addObject:dict];
        }
      
        
        [dict setValue:array forKey:LINKS];

    }
    
    if([dict count] >0){
        NSError *error = nil;
        NSData* json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString * jsonString = [[NSString alloc ] initWithData:json encoding:NSUTF8StringEncoding];
        
        return [Util sanitizeString:jsonString];
        
       
    }else{
        return nil;
    }
    
   
}

/**
 * Method to get the @[names] mentions strings
 */
-(NSArray*) getMentions:(NSArray*)array{
    NSPredicate * mentionPredicate = [NSPredicate predicateWithFormat:MENTION_PREDICATE, @"@"];
    NSArray *mentions = [array filteredArrayUsingPredicate:mentionPredicate];
    NSMutableArray * newArray = [[NSMutableArray alloc]init];
    for(NSString * mention in mentions){
        NSString * newString = [mention stringByReplacingOccurrencesOfString:@"@" withString:@""];
        [newArray addObject:newString];
    }
    return newArray;
    
}

/**
 * Method to get the emoticons
 */
-(NSArray*) getEmoticons:(NSArray*)array{
    NSPredicate * emoticonPredicate =  [NSPredicate predicateWithFormat:EMOTICON_PREDICATE,@"(",@")"];
    NSArray *emoticons = [array filteredArrayUsingPredicate:emoticonPredicate];
    NSMutableArray * newArray = [[NSMutableArray alloc]init];
    for(NSString * emoticon in emoticons){
        
        NSString * newString = [emoticon stringByReplacingOccurrencesOfString:@"(" withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@")" withString:@""];
      
        BOOL valid = [Util isAlphaNumeric:newString];
        //add only the valid emoticons
        if(valid){
             [newArray addObject:newString];
        }
       
    }
    return newArray;
}

/**
 *  Method to get the links
 */
-(NSArray*) getLinks:(NSArray*) array;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", URL_PREDICATE];
    NSArray * links = [array filteredArrayUsingPredicate:predicate];
    NSMutableArray * newArray = [[NSMutableArray alloc] init];
    for(NSString * link in links){
        NSString * newlink =  [link stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [newArray addObject:newlink];
    }
    
    return newArray;
    
}

/**
 *
 *  Method to get the title in specified url
 */
-(NSString*) getTitleWithURL:(NSString*)url{
    NSString * htmlCode = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSASCIIStringEncoding error:nil];
    if(htmlCode!=nil && htmlCode.length > 0){
        NSString * start = @"<title>";
        NSRange range1 = [htmlCode rangeOfString:start];
        
        NSString * end = @"</title>";
        NSRange range2 = [htmlCode rangeOfString:end];
        
        NSString * subString = [htmlCode substringWithRange:NSMakeRange(range1.location + 7, range2.location - range1.location - 7)];
        if(subString)
            subString = (subString !=nil) ? [subString stringByReplacingOccurrencesOfString:@"\n" withString:@""] : subString;
          subString = (subString !=nil) ? [subString stringByReplacingOccurrencesOfString:@"\t" withString:@""] : subString;
          subString = (subString !=nil) ? [subString stringByReplacingOccurrencesOfString:@"\r" withString:@""] : subString;

        if([subString length] > MAX_TITLE_LEN){
            return [subString substringToIndex:MAX_TITLE_LEN];
        }
        return subString;
    }
    return nil;
    
    
}

@end
