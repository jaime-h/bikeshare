//
//  ViewController.m
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/6/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ViewController.h"
#import "DivyAddressPoint.h"
#import "AnnotationsMapViewViewController.h"
#import "UIColor+PXExtentions.h"
#import "DirectionsAndMapViewController.h"

#import "LocationManager.h"
#import "ConnectionManager.h"
#import "JSONParser.h"
#import "Utilities.h"
#import "Constants.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIAccelerometerDelegate, UIAlertViewDelegate, ConnectionManagerDelegate >
{
    ConnectionManager* connectionManager;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    MKCoordinateSpan mapSpan;
    CLLocationCoordinate2D mapCenter;
}

@end

@implementation ViewController

#pragma mark ViewController LifeCycle 

- (void)viewDidLoad
{
    [super viewDidLoad];

    // http://stackoverflow.com/questions/12497940/uirefreshcontrol-without-uitableviewcontroller/12502450#12502450
    // http://stackoverflow.com/questions/10291537/pull-to-refresh-uitableview-without-uitableviewcontroller?rq=1

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    locationManager = [LocationManager sharedInstance];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    mapSpan = MKCoordinateSpanMake(0.025, 0.025);

    //create the connection manager and set the delegate
    connectionManager = [ConnectionManager sharedInstance];
    connectionManager.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    [self.myTableView setSeparatorColor:COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:COLOR}];
    [self.myTableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
}

-(void)handleRefresh:(UIRefreshControl *)refreshControl
{
    [connectionManager downloadStationData];
    [refreshControl endRefreshing];
}

#pragma mark TableViewDelegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _transferableDivvyLocations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseThisCellIdentifier"];

    DivyAddressPoint *location = _transferableDivvyLocations[indexPath.row];
    cell.textLabel.text = location.stationName;

    UIColor *myColor = [UIColor pxColorWithHexValue:@"#3DB7E4"];
    cell.textLabel.textColor = myColor;

    NSInteger NumberOfBikes; NSInteger NumberOfDocks; NSInteger NumberOfAllDocks;
    NumberOfBikes = [location.availableBikes intValue];
    NumberOfDocks = [location.availableDocks intValue];
  
  /*
   NumberOfAllDocks = [location.totalDocks  intValue];

    Using total docs to determine the % of free bikes and free docks

    float percentageOfFreeBikes; float percentageOfFreeDocks;

    percentageOfFreeBikes = (float) NumberOfBikes/NumberOfAllDocks;
    percentageOfFreeDocks = (float) NumberOfDocks/NumberOfAllDocks;
     
     */

    int distance = roundf([location.placemark.location distanceFromLocation:locationManager.location]);

    NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available, Dist <%2.2f> mi", (long)NumberOfBikes, (long)NumberOfDocks, (distance/1609.34)];

    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.textColor = myColor;

    return cell;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

        if ([segue.identifier isEqualToString:@"ShowAnnotationsOnMap"])
        {
            // Pass the data needed to create the annotations on the map
            AnnotationsMapViewViewController *vc = segue.destinationViewController;
            vc.navigationItem.title = @"Bike Share Map";
            vc.annotationsArray = _transferableDivvyLocations;
        }
        if ([segue.identifier isEqualToString:@"ShowDetails"])
        {
            DirectionsAndMapViewController *vc = segue.destinationViewController;

            NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
            DivyAddressPoint *place = _transferableDivvyLocations[indexPath.row];

            vc.divvyStationLocation = place;
            vc.navigationItem.title = @"Detail Route Information";
        }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // http://zeroheroblog.com/ios/how-to-use-multiple-uialertview-components-inside-one-view-controller-in-ios
    // http://stackoverflow.com/questions/12731460/multiple-uialertviews-in-the-same-view
    // Using tags to differentiate between mulitple alertviews

    if (buttonIndex == 0)
    {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
 }


#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // http://stackoverflow.com/questions/19393458/ios7-core-location-not-updating?rq=1
    currentLocation = locations.lastObject;
    [locationManager stopUpdatingLocation];

    //download the data once we have the user location. The user's location is required to filter the list of stations
    [connectionManager downloadStationData];
}

#pragma mark ConnectionManagerDelegateMethod

/*
 * Delegate method to receive the list of DivvyAddressPoint (stations) objects. This method receives an array
 * of station object or an error if the data was not parsed
 * @param NSArray
 * @param NSError
 * @param ConnectionManager
 */
- (void)didFinishDownloadingData:(NSArray *)data error:(NSError *)error connectionManager:(ConnectionManager *)manager
{
    //[self filterStationsByRadius:data];

    if (!error)
    {


        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            //the radius of a rectangle is 1/2 diagonal = sqrt( length^2 + width^2) / 2
            float radius = sqrtf( (0.025* 0.025) + (0.025* 0.025))  * 0.5;

            // Checking what is in here..... As it is not getting updated...
            NSLog(@"At didFinishDownloadingData");
            NSLog(@"locationManager.location --> %@", locationManager.location);
            NSLog(@"currentLocation          --> %@", currentLocation);

            _transferableDivvyLocations = [Utilities filterStationsByRadius:currentLocation stations:data radius:radius];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myTableView reloadData];
            });
        });

    }
    else
    {

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

@end
