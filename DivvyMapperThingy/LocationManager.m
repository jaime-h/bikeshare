//
//  LocationManager.m
//  ChiTownBikeShare
//
//  Created by user on 9/8/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//+(instancetype)sharedInstance
//{
//    static LocationManager* _sharedInstance;
//    static dispatch_once_t onceToken;
//    
//    dispatch_once(&onceToken, ^{
//        _sharedInstance = [[LocationManager alloc]init];
//    });
//    
//    return _sharedInstance;
//}


+(CLLocationManager*)sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CLLocationManager alloc]init];
    });

    return _sharedInstance;
}

/* Override the standard getter method to use lazy instantiation to load the location manager
 * request whenInUseAuthorization and set the desired accuracy.
 */
//- (CLLocationManager *)locationManager
//{
//    if (!_locationManager) {
//        _locationManager = [[CLLocationManager alloc]init]; //create location manager
//        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//        [_locationManager requestWhenInUseAuthorization];   //request authorization
//    }
//    return _locationManager;
//}


@end
