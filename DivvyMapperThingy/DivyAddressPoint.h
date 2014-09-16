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

//TODO: change variable types to reflect the desired type
@property (nonatomic) NSString *stationName;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lng;
@property (nonatomic) NSString *address;
@property (nonatomic) MKPlacemark *placemark;
@property (nonatomic) NSString *availableDocks;
@property (nonatomic) NSString *totalDocks;
@property (nonatomic) NSString *availableBikes;
@property (nonatomic) NSString *bikeDockPinColor;
@property (nonatomic)CLLocationCoordinate2D location;

@end
