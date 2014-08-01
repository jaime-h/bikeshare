//
//  YellowYellow.h
//  ChiTownBikeShare
//
//  Created by Jaime Hernandez on 8/1/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MasterPointAnnotation.h"

@interface YellowYellow : MasterPointAnnotation

@property NSString *stationName;
@property NSString *lat;
@property NSString *lng;
@property NSString *address;
@property MKPlacemark *placemark;
@property NSString *availableDocks;
@property NSString *totalDocks;
@property NSString *availableBikes;
@property NSString *bikeDockPinColor;

@end
