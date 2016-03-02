//
//  MessageManager.h
//  AtlassianTest
//
//  Created by Carmelita Mendoza on 2/3/16.
//  Copyright (c) 2016 Carmelita Mendoza. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Constructor class that parse the message to Json String
 */
@interface MessageManager : NSObject



/**
 * Initialization Method that return the singleton object class
 * @return MessageManager the singleton object
 */
+(MessageManager*) sharedManager;

/**
 * Method that parse the message to json string
 * @return messagse the message string object
 */
-(NSString*) messagetoJsonString:(NSString*)message;

@end
