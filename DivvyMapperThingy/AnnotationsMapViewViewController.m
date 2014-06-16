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
    
    [self checkLocationServices];
    
    
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

        NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available", (long)NumberOfBikes, (long)NumberofDocks];

        point.subtitle = detailText;

        [self.annotationsMapView addAnnotation:point];
        [self.annotationsMapView reloadInputViews];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    DivvyMKPointAnnotation *point = [DivvyMKPointAnnotation new];

    point.stationName = [NSString stringWithFormat:@"%lu",(unsigned long)[self.annotationsMapView.annotations count]];

    [self.annotationsMapView reloadInputViews];

}

-(void)checkLocationServices
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
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
    else
    {
        // No permissions - let them know why...
        // Settings
        // Also check to see if they just want to see the location of the stations...
        // Maybe geocode an address and display it?
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"App Permission Denied"
                                                    message:@"To re-enable, please go to \n Settings>Privacy>Location Services"
                                                   delegate:self //set delegate for UIAlertView
                                          cancelButtonTitle:@"Show locations"
                                          otherButtonTitles:@"Return to list", nil];
        
        
        [self addParallax:av];
        av.tag = 001;
        [av show];
        
    }
}

- (void)addParallax:(UIAlertView *)av
{
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    verticalMotionEffect.minimumRelativeValue = @(-50);
    verticalMotionEffect.maximumRelativeValue = @(50);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    horizontalMotionEffect.minimumRelativeValue = @(-50);
    horizontalMotionEffect.maximumRelativeValue = @(50);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    [av addMotionEffect:group];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    // Differentiating between two different alertviews with different actions...
    // http://stackoverflow.com/questions/9976471/uialertviewdelegateclickedbuttonatindex-and-two-buttons/9976689#9976689
    
    if (alertView.tag == 001)
    {
        if (buttonIndex == 0)
        {
            // Display annotations with Madison & State Street coordinates
            // 41.8783543,-87.6297999
            
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(41.8783543, -87.6297999);
            MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.025, 0.025);
            MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
            
            self.annotationsMapView.region = region;
            self.annotationsMapView.delegate = self;
            
            [self loadAnnotationsOnMap];
            
        }
        
        if (buttonIndex == 1)
        {
            // Let's dismiss this and go to the previous one..
            [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController popViewControllerAnimated:YES];

        }
        
    }
}

@end
