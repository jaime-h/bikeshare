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

#import "RedRed.h"
#import "RedYellow.h"
#import "RedGreen.h"

#import "YellowRed.h"
#import "YellowYellow.h"
#import "YellowGreen.h"

#import "GreenRed.h"
#import "GreenYellow.h"
#import "GreenGreen.h"

#import "MasterPointAnnotation.h"

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
- (MKPinAnnotationView *)createGenericPicHeader:(id)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.animatesDrop = YES;
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bike-1"]];
    pin.leftCalloutAccessoryView = iconView;
    pin.pinColor = MKPinAnnotationColorPurple;
    return pin;
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Need to sort out clustering and zoom levels.... 

    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        // This will return the "blue dot"
        return nil;
    }

    else if ([annotation isKindOfClass:[RedRed class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"RedRed"];
        return pin;
    }
    else if ([annotation isKindOfClass:[RedYellow class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"RedYellow"];
        return pin;
    }

    else if ([annotation isKindOfClass:[RedGreen class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"RedGreen-1"];
        return pin;
    }
    else if ([annotation isKindOfClass:[YellowRed class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"YellowRed"];
        return pin;
    }
    else if ([annotation isKindOfClass:[YellowYellow class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"YellowYellow-1"];
        return pin;
    }
    else if ([annotation isKindOfClass:[YellowGreen class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"YellowGreen"];
        return pin;
    }
    else if ([annotation isKindOfClass:[GreenRed class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"GreenRed-1"];
        return pin;
    }
    else if ([annotation isKindOfClass:[GreenYellow class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"GreenYellow"];
        return pin;
    }
    else if ([annotation isKindOfClass:[GreenGreen class]])
    {
        MKPinAnnotationView *pin;
        pin = [self createGenericPicHeader:annotation];
        pin.image = [UIImage imageNamed:@"GreenGreen"];
        return pin;
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

- (void)createAnnotationsFromItems:(DivyAddressPoint *)item point:(MasterPointAnnotation *)point NumberOfDocks:(NSInteger)NumberOfDocks NumberOfBikes:(NSInteger)NumberOfBikes
{
    point.coordinate = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude);
    point.stationName = item.stationName;
    point.availableBikes = item.availableBikes;
    point.availableDocks = item.availableDocks;
    
    point.title = item.stationName;
    NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available", (long)NumberOfBikes, (long)NumberOfDocks];
    
    point.subtitle = detailText;
}

-(void)loadAnnotationsOnMap
{
    for (DivyAddressPoint *item in self.annotationsArray)
    {

        // Calculate the percentages of Docks & Bikes so that I can drop the corresponding pin..
        NSInteger NumberOfBikes; NSInteger NumberOfDocks; NSInteger NumberOfAllDocks;
        NumberOfBikes = [item.availableBikes intValue];
        NumberOfDocks = [item.availableDocks intValue];
        NumberOfAllDocks = [item.totalDocks  intValue];

        NSString *bikeRAGColor = [NSString new];
        NSString *dockRAGColor = [NSString new];

        float percentageOfFreeBikes; float percentageOfFreeDocks;

        percentageOfFreeBikes = (float) NumberOfBikes/NumberOfAllDocks;
        percentageOfFreeDocks = (float) NumberOfDocks/NumberOfAllDocks;

        if (percentageOfFreeBikes < 0.34)
        {
            bikeRAGColor = @"RED";
        }
        else if (percentageOfFreeBikes >= 0.34 && percentageOfFreeBikes <= 0.66)
        {
            bikeRAGColor = @"YELLOW";
        }
        else if (percentageOfFreeBikes > 0.66)
        {
            bikeRAGColor = @"GREEN";
        }

        if (percentageOfFreeDocks < 0.34)
        {
            dockRAGColor = @"RED";
        }
        else if (percentageOfFreeDocks >= 0.34 && percentageOfFreeDocks <= 0.66)
        {
            dockRAGColor = @"YELLOW";
        }
        else if (percentageOfFreeDocks > 0.66)
        {
            dockRAGColor = @"GREEN";
        }

        if ([bikeRAGColor isEqualToString:@"RED"] && [dockRAGColor isEqualToString:@"RED"])
        {

            RedRed *point = [RedRed new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];

        }
        else if ([bikeRAGColor isEqualToString:@"RED"] && [dockRAGColor isEqualToString:@"YELLOW"])
        {

            RedYellow *point = [RedYellow new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];

        }
        else if ([bikeRAGColor isEqualToString:@"RED"] && [dockRAGColor isEqualToString:@"GREEN"])
        {

            RedGreen *point = [RedGreen new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];

        }
        else if ([bikeRAGColor isEqualToString:@"YELLOW"] && [dockRAGColor isEqualToString:@"RED"])
        {
            YellowRed *point = [YellowRed new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }
        else if ([bikeRAGColor isEqualToString:@"YELLOW"] && [dockRAGColor isEqualToString:@"YELLOW"])
        {
            YellowYellow *point = [YellowYellow new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }
        else if ([bikeRAGColor isEqualToString:@"YELLOW"] && [dockRAGColor isEqualToString:@"GREEN"])
        {
            YellowGreen *point = [YellowGreen new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }
        else if ([bikeRAGColor isEqualToString:@"GREEN"] && [dockRAGColor isEqualToString:@"RED"])
        {
            GreenRed *point = [GreenRed new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }
        else if ([bikeRAGColor isEqualToString:@"GREEN"] && [dockRAGColor isEqualToString:@"YELLOW"])
        {
            GreenYellow *point = [GreenYellow new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }
        else if ([bikeRAGColor isEqualToString:@"GREEN"] && [dockRAGColor isEqualToString:@"GREEN"])
        {
            GreenGreen *point = [GreenGreen new];

            [self createAnnotationsFromItems:item point:point NumberOfDocks:NumberOfDocks NumberOfBikes:NumberOfBikes];

            [self.annotationsMapView addAnnotation:point];
            [self.annotationsMapView reloadInputViews];
        }


//        DivvyMKPointAnnotation *point = [DivvyMKPointAnnotation new];
//        point.coordinate = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude);
//        point.stationName = item.stationName;
//        point.availableBikes = item.availableBikes;
//        point.availableDocks = item.availableDocks;
//
//        point.title = item.stationName;
//        NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available", (long)NumberOfBikes, (long)NumberOfDocks];
//
//        point.subtitle = detailText;
//
//        point.bikeDockPinColor = item.bikeDockPinColor;

//        [self.annotationsMapView addAnnotation:point];
//        [self.annotationsMapView reloadInputViews];
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
