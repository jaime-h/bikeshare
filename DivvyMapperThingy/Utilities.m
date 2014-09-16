//
//  Utilities.m
//  ChiTownBikeShare
//
//  Created by user on 9/15/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "Utilities.h"
#import "DivyAddressPoint.h"

@implementation Utilities

/*
 * Method to deteromine if a given DivvyAddressPoint is within a specified radius of the user's
 * location. This uses the standard Euclidian distance formula
 * @param CLLocationCoordinate2D location
 * @param Float radius
 */
+(BOOL)determineIfLocationisWithinRadius:(CLLocationCoordinate2D)userLocation stationLocation:(CLLocationCoordinate2D)stationLocation radius:(float)radius
{
    
    //calculate the distance from the users current location
    //distance formulae d = sqrt (x1 - x2)^2 + (y1 -  y2)^2
    float x = powf(fabs(userLocation.latitude - stationLocation.latitude), 2);
    float y = powf(fabs(userLocation.longitude - stationLocation.longitude), 2);
    float distance  = sqrtf(x + y);
    
    if (distance < radius) {
        return YES;
    }
    
    return NO;
}

/*
 * Secondary method to use the map views mix and max points to determine if the divvy location
 * is within the map view shown on the screen.
 * @param CLLocationCoordinate2D location
 * @param CGRect rectangle representing the map boundaries
 */
+(BOOL)determineIfPointIsWithinMapView:(CLLocationCoordinate2D)location rect:(CGRect)rect
{
    
    if (location.latitude > rect.origin.x && location.latitude < rect.size.width && location.longitude < rect.origin.y && location.longitude > rect.size.height) {
        return YES;
    }
    return NO;
    
}

/*
 * Filter the list of stations returned by the url request to just those within a specified
 * radius of the user. The radius of the user is initiall set at application launch time and altered
 * based on the user's action on the map screen. The list of stations objects is update
 * @param NSArray array of custom model objects
 */
+(NSArray*)filterStationsByRadius:(CLLocation*)location stations:(NSArray*)stations radius:(float)radius
{
    
    NSArray* results;
    NSMutableArray* filteredStations = [NSMutableArray new];
    
    for (DivyAddressPoint* station in stations) {
        
        if([Utilities determineIfLocationisWithinRadius:location.coordinate stationLocation:station.location radius:radius])
        {
            [filteredStations addObject:station];
        }
    }
    
    //sort the list of stations from closest to farthest
    results = [filteredStations sortedArrayUsingComparator:^NSComparisonResult(MKMapItem* obj1, MKMapItem* obj2)
               {
                   float d1 = [obj1.placemark.location distanceFromLocation:location];
                   float d2 = [obj2.placemark.location distanceFromLocation:location];
                   if (d1 < d2)
                   {
                       return NSOrderedAscending;
                   }
                   else
                   {
                       return NSOrderedDescending;
                   }
                   
               }];
    
    NSLog(@"utilites class stations %d",results.count);
    return results;
}


@end
