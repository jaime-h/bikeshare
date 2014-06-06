//
//  DirectionsAndMapViewController.m
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/15/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "DirectionsAndMapViewController.h"
#import "ViewController.h"
#import "UIColor+PXExtentions.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DirectionsAndMapViewController () <UIAlertViewDelegate>

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet MKMapView  *divvyLocationDetailMap;
@property (weak, nonatomic) IBOutlet UITextView *divvyLocationDirectionsTextView;
@property (weak, nonatomic) IBOutlet UITextField *freeBikesTextField;
@property (weak, nonatomic) IBOutlet UITextField *freeDocksTextField;

@end

@implementation DirectionsAndMapViewController

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
    [super viewWillAppear:YES];

    self.locationManager = [CLLocationManager new];
    [self.divvyLocationDetailMap setShowsUserLocation:YES];
    [self.locationManager startUpdatingLocation];

    [self determineMapDisplayProperties];

    [self showSelectedDivvyAnnotation];
    [self createDirectionsFromLocationToStation];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self colorTextLables];

    // Create an offset since the textview believes that it is behind something..
    self.divvyLocationDirectionsTextView.contentInset = UIEdgeInsetsMake(-42.5,1.0,0,0.0);
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)showSelectedDivvyAnnotation
{
    MKPointAnnotation *annotation = [MKPointAnnotation new];

    CGFloat latitude  = (CGFloat)[self.divvyStationLocation.lat floatValue];
    CGFloat longitude = (CGFloat)[self.divvyStationLocation.lng floatValue];
    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    annotation.title      = self.divvyStationLocation.stationName;

    NSInteger NumberOfBikes; NSInteger NumberofDocks;
    NumberOfBikes = [self.divvyStationLocation.availableBikes intValue];
    NumberofDocks = [self.divvyStationLocation.availableDocks intValue];

    NSString *detailText = [NSString stringWithFormat:@"%i Bikes, %i Docks Available", NumberOfBikes, NumberofDocks];

    annotation.subtitle = detailText;

    [self.divvyLocationDetailMap addAnnotation:annotation];
    [self.divvyLocationDetailMap reloadInputViews];

}

-(void)createDirectionsFromLocationToStation
{
    MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:self.divvyStationLocation.placemark.coordinate addressDictionary:nil];
    MKMapItem   *mapItem   = [[MKMapItem alloc]initWithPlacemark:placemark];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];

    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;

    int distance = roundf([mapItem.placemark.location distanceFromLocation:self.locationManager.location]);

    if ((distance/1609.34) <= 75.00f)
    {

        request.requestsAlternateRoutes = NO;
        request.transportType = MKDirectionsTransportTypeWalking;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
         {
             if (error)
             {
                 UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"No Internet Connection"
                                                             message:@"Please try again in a few minutes @D&MVC"
                                                            delegate:nil //set delegate for UIAlertView
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];

                 [av show];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }
             else
             {
                 [self showRoute:response];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }
         }];

        [self.locationManager stopUpdatingLocation];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"To far from Chicago"
                                                    message:@"Please move within Chicago city limits"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

        [av show];
        self.freeBikesTextField.text = @"To Far"; self.freeBikesTextField.textColor = [UIColor redColor];
        self.freeDocksTextField.text = @"To Far"; self.freeDocksTextField.textColor = [UIColor redColor];
    }

}


-(void)showRoute:(MKDirectionsResponse *)response
{
    UIColor *myColor = [UIColor pxColorWithHexValue:@"#3DB7E4"];
    self.divvyLocationDirectionsTextView.text = @"";
    for (MKRoute *route in response.routes)
    {
        [self.divvyLocationDetailMap addOverlay:route.polyline level:MKOverlayLevelAboveRoads];

        for (MKRouteStep *step in route.steps)
        {
            self.divvyLocationDirectionsTextView.textColor = myColor;
            self.divvyLocationDirectionsTextView.text = [NSString stringWithFormat:@"%@\n%@", self.divvyLocationDirectionsTextView.text, step.instructions];
        }
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];

    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth   = 5.0;
    
    return renderer;
}

-(void)determineMapDisplayProperties
{
    // Determine what the center point is between the station and the user show the map with that
    // http://stackoverflow.com/questions/10559219/determining-midpoint-between-2-cooridinates
    CGFloat latitude  = (CGFloat)[self.divvyStationLocation.lat floatValue];
    CGFloat longitude = (CGFloat)[self.divvyStationLocation.lng floatValue];

    double lon1 = longitude * M_PI / 180;
    double lon2 = self.locationManager.location.coordinate.longitude * M_PI / 180;

    double lat1 = latitude * M_PI / 180;
    double lat2 = self.locationManager.location.coordinate.latitude * M_PI / 180;

    double dLon = lon2 - lon1;

    double x = cos(lat2) * cos(dLon);
    double y = cos(lat2) * sin(dLon);

    double lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
    double lon3 = lon1 + atan2(y, cos(lat1) + x);

    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((lat3 * 180 / M_PI),(lon3 * 180 / M_PI));

    // Need to calculate the distance so that I can get the span for the map!
    int distance = roundf([self.divvyStationLocation.placemark.location distanceFromLocation:self.locationManager.location]);

    /*
     Ok - we don't need the below because we are going to use distance -
     MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.025, 0.025);
     */


    // Ok - we know the distance, let's use that to set the region for the map to display. 1.25 seems to be a good compromise
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, (distance * 1.25), distance * 1.25);

    self.divvyLocationDetailMap.region = region;
    self.divvyLocationDetailMap.delegate = self;

}

-(void)colorTextLables
{
    UIColor *myColor = [UIColor pxColorWithHexValue:@"#3DB7E4"];

    [[self.divvyLocationDirectionsTextView layer] setBorderColor:[myColor CGColor]];
    [[self.divvyLocationDirectionsTextView layer] setBorderWidth:1.0];
    [[self.divvyLocationDirectionsTextView layer] setCornerRadius:10];

    self.freeBikesTextField.text = [NSString stringWithFormat:@"Bikes Open %@", self.divvyStationLocation.availableBikes];
    self.freeDocksTextField.text = [NSString stringWithFormat:@"Docks Open %@", self.divvyStationLocation.availableDocks];

    self.freeBikesTextField.textColor = myColor;
    self.freeDocksTextField.textColor = myColor;

    [[self.freeBikesTextField layer] setBorderColor:[myColor CGColor]];
    [[self.freeBikesTextField layer] setBorderWidth:1.0];
    [[self.freeBikesTextField layer] setCornerRadius:10];

    [[self.freeDocksTextField layer] setBorderColor:[myColor CGColor]];
    [[self.freeDocksTextField layer] setBorderWidth:1.0];
    [[self.freeDocksTextField layer] setCornerRadius:10];

}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Let's dismiss this and go to the previous one..
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

@end
