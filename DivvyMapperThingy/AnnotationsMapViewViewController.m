//
//  AnnotationsMapViewViewController.m
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/7/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "AnnotationsMapViewViewController.h"
#import "DivyAddressPoint.h"
#import "ViewController.h"
#import "DivvyMKPointAnnotation.h"
#import "UIColor+PXExtentions.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AnnotationsMapViewViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@end

@implementation AnnotationsMapViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationManager = [CLLocationManager new];
    [self.annotationsMapView setShowsUserLocation:YES];
    [self.locationManager startUpdatingLocation];

    CLLocationCoordinate2D centerCoordinate = self.locationManager.location.coordinate;

    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.025, 0.025);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);

    self.annotationsMapView.region = region;
    self.annotationsMapView.delegate = self;

    [self loadAnnotationsOnMap];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Need to sort out clustering and zoom levels.... 

    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        // This will return the "blue dot"
        return nil;
    }
    else 
    {
        // This is the return for a cluster

        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pin.canShowCallout = YES;
        pin.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.animatesDrop = YES;
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bike-1"]];
        pin.leftCalloutAccessoryView = iconView;
        pin.pinColor = MKPinAnnotationColorPurple;

        return pin;

        }
    [self.locationManager stopUpdatingLocation];

}

-(void)loadAnnotationsOnMap
{
    for (DivyAddressPoint *item in self.annotationsArray)
    {

        DivvyMKPointAnnotation *point = [DivvyMKPointAnnotation new];
        point.coordinate = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude);
        point.stationName = item.stationName;
        point.availableBikes = item.availableBikes;
        point.availableDocks = item.availableDocks;

        point.title = item.stationName;

        NSInteger NumberOfBikes; NSInteger NumberofDocks;
        NumberOfBikes = [point.availableBikes intValue];
        NumberofDocks = [point.availableDocks intValue];

        NSString *detailText = [NSString stringWithFormat:@"%i Bikes, %i Docks Available", NumberOfBikes, NumberofDocks];

        point.subtitle = detailText;

        [self.annotationsMapView addAnnotation:point];
        [self.annotationsMapView reloadInputViews];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    DivvyMKPointAnnotation *point = [DivvyMKPointAnnotation new];

    point.stationName = [NSString stringWithFormat:@"%d",[self.annotationsMapView.annotations count]];

    [self.annotationsMapView reloadInputViews];

}
@end
