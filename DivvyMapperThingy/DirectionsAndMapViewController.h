//
//  DirectionsAndMapViewController.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/15/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "DivyAddressPoint.h"

@interface DirectionsAndMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property DivyAddressPoint *divvyStationLocation;

@end
