//
//  AnnotationsMapViewViewController.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/7/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "DivyAddressPoint.h"

@interface AnnotationsMapViewViewController : UIViewController

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CLLocationCoordinate2D currentCenter;
@property int currenDist;
@property (strong, nonatomic) IBOutlet MKMapView *annotationsMapView; // MKMapView

@property (strong, nonatomic) NSArray *annotationsArray;


@end
