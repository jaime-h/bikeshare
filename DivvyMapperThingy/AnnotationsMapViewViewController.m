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

#import "LocationManager.h"
#import "ConnectionManager.h"
#import "Utilities.h"


@interface AnnotationsMapViewViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property(nonatomic)ConnectionManager* connectionManager;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D currentCenter;
@property (nonatomic) int currenDist;

@property (nonatomic) CLLocation* center;

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

#pragma mark ViewController LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[LocationManager sharedInstance]locationManager];
    self.locationManager.delegate = self;
    self.connectionManager = [ConnectionManager sharedInstance];
    self.connectionManager.delegate = (id)self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkLocationServices];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];

}

#pragma mark MKMapViewDelegate Methods

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
        // Fall through for any other scenarios

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

        // Calculate the percentages of Docks & Bikes so that I can drop the corresponding pin..
        NSInteger NumberOfBikes; NSInteger NumberOfDocks;  NSInteger NumberOfAllDocks;
        NumberOfBikes = [item.availableBikes intValue];
        NumberOfDocks = [item.availableDocks intValue];
        NumberOfAllDocks = [item.totalDocks  intValue];

        float percentageOfFreeBikes; float percentageOfFreeDocks;

        percentageOfFreeBikes = (float) NumberOfBikes/NumberOfAllDocks;
        percentageOfFreeDocks = (float) NumberOfDocks/NumberOfAllDocks;

        DivvyMKPointAnnotation *point = [DivvyMKPointAnnotation new];
        point.coordinate = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude);
        point.stationName = item.stationName;
        point.availableBikes = item.availableBikes;
        point.availableDocks = item.availableDocks;

        point.title = item.stationName;
        NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available", (long)NumberOfBikes, (long)NumberOfDocks];

        point.subtitle = detailText;

        point.bikeDockPinColor = item.bikeDockPinColor;

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

#pragma mark LocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@",[error userInfo]);
}

#pragma mark - MKMapView Region changes
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    NSLog(@"span x:%f y:%f", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    NSLog(@"center x:%f y:%f", mapView.region.center.latitude, mapView.region.center.longitude);

    //set the maps center to be the current "user" location
    self.center = [[CLLocation alloc] initWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];

    //get new station data
    [self.connectionManager downloadStationData];
}

#pragma mark - ConnectionManagerDelegate method


/*
 * Delegate method called by the ConnectionManager when the JSON data has been downloaed and parsed
 * @param NSArray custom model object array
 * @return void
 */
-(void)didFinishDownloadingData:(NSArray*)data error:(NSError*)error connectionManager:(ConnectionManager*)manager
{
    if (!error) {

        // FIXME: Need to account for map scolling not just zoom

        //filter the array of stations on a background thread, once competed, update the map view by reloading the
        //annotations. We need to update the UI so we cannot use performSelectorInBackground
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            //the radius of a rectangle is 1/2 diagonal = sqrt( length^2 + width^2) / 2
            float diagonal = sqrtf( powf(self.annotationsMapView.region.span.longitudeDelta, 2.0) + (powf(self.annotationsMapView.region.span.latitudeDelta, 2.0))) * 0.5;

            self.annotationsArray = [Utilities filterStationsByRadius:self.center stations:data radius:diagonal];

            //UI updates must be done on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadAnnotationsOnMap];
            });

        });


    }
    else {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:error.localizedDescription
                                                    message:@"Please try again in a few minutes"
                                                   delegate:self //set delegate for UIAlertView
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];

        //UI updates must be done on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [av show];
        });
    }
    
}

-(void)checkLocationServices
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        [self.annotationsMapView setShowsUserLocation:YES];
        [self.locationManager startUpdatingLocation];


        // Checking to see if this is for ios 8
        // If so - set the the api..
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestWhenInUseAuthorization];
        }


        //[self.locationManager startUpdatingLocation];
        
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
