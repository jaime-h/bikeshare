//
//  JSONParser.m
//  ChiTownBikeShare
//
//  Created by user on 9/9/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "JSONParser.h"
#import "LocationManager.h"
#import "DivyAddressPoint.h"

@implementation JSONParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*
 * Method to parse the JSON data into custom model object (DivvyAddressPoint). When the method completes, it 
 * will provide an NSArray of objects created from the JSON data via a completion block
 * @param NSData data to parse
 * @param JSONParserCompletion completion block
 * @return void
 */
-(void)parseJSONData:(NSData*)data withCompletion:(JSONParserCompletion)completion
{
    NSError* error;
    
    NSDictionary *outerContainer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSArray *allDivvyLocations = outerContainer[@"stationBeanList"];
    
    NSMutableArray* sortArray = [NSMutableArray new];
    [sortArray removeAllObjects];
    
    for (NSDictionary *point in allDivvyLocations)
    {
        DivyAddressPoint *divvyLocationPoint = [DivyAddressPoint new];
        
        divvyLocationPoint.stationName = point[@"stationName"];
        divvyLocationPoint.address     = point[@"location"];
        
        divvyLocationPoint.lat         = point[@"latitude"];
        divvyLocationPoint.lng         = point[@"longitude"];
        
        
        CGFloat latitude  = (CGFloat)[divvyLocationPoint.lat floatValue];
        CGFloat longitude = (CGFloat)[divvyLocationPoint.lng floatValue];
        
        CLLocationCoordinate2D placeCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:placeCoordinate addressDictionary:nil];
        divvyLocationPoint.placemark = placemark;
        
        divvyLocationPoint.availableBikes = point[@"availableBikes"];
        divvyLocationPoint.availableDocks = point[@"availableDocks"];
        
        // Adding total docks for calculation - 07272014
        divvyLocationPoint.totalDocks     = point[@"totalDocks"];
        
        [sortArray addObject:divvyLocationPoint];
        
    }
    
    //use the completion block to return the data
    completion(sortArray,error);
    
}

@end
