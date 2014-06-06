//
//  DivvyMKPointAnnotation.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/7/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DivvyMKPointAnnotation : MKPointAnnotation

@property NSString *stationName;
@property NSString *lat;
@property NSString *lng;
@property NSString *address;
@property MKPlacemark *placemark;
@property NSString *availableDocks;
@property NSString *totalDocks;
@property NSString *availableBikes;


@end
