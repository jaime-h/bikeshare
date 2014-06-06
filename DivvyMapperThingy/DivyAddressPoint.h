//
//  DivyAddressPoint.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/6/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DivyAddressPoint : NSMutableArray

@property NSString *stationName;
@property NSString *lat;
@property NSString *lng;
@property NSString *address;
@property MKPlacemark *placemark;
@property NSString *availableDocks;
@property NSString *totalDocks;
@property NSString *availableBikes;

@end
