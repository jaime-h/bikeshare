//
//  Utilities.h
//  ChiTownBikeShare
//
//  Created by user on 9/15/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Utilities : NSObject

+(BOOL)determineIfLocationisWithinRadius:(CLLocationCoordinate2D)userLocation stationLocation:(CLLocationCoordinate2D)stationLocation radius:(float)radius;

+(NSArray*)filterStationsByRadius:(CLLocation*)location stations:(NSArray*)stations radius:(float)radius;

@end
