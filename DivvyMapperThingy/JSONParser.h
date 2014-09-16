//
//  JSONParser.h
//  ChiTownBikeShare
//
//  Created by user on 9/9/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>

//define a custom callback block
typedef void (^JSONParserCompletion)(NSArray* data, NSError* error);

@interface JSONParser : NSObject

-(void)parseJSONData:(NSData*)data withCompletion:(JSONParserCompletion)completion;

@end


