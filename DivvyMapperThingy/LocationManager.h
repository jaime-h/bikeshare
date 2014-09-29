//
//  LocationManager.h
//  ChiTownBikeShare
//
//  Created by user on 9/8/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject 

+(CLLocationManager *)sharedInstance;

// @property (nonatomic)CLLocationManager* locationManager;

@end



