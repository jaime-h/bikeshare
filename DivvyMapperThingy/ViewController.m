//
//  ViewController.m
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/6/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "ViewController.h"
#import "DivyAddressPoint.h"
#import "AnnotationsMapViewViewController.h"
#import "UIColor+PXExtentions.h"
#import "DirectionsAndMapViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIAccelerometerDelegate, UIAlertViewDelegate>
{
    NSArray *transferableDivvyLocations;
    NSMutableArray *sortArray;
    DivyAddressPoint *divvyLocation;
}

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gatherDivvyData];
    
    // http://stackoverflow.com/questions/12497940/uirefreshcontrol-without-uitableviewcontroller/12502450#12502450
    // http://stackoverflow.com/questions/10291537/pull-to-refresh-uitableview-without-uitableviewcontroller?rq=1
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    UIColor *mycolor = [UIColor pxColorWithHexValue:@"#3DB7E4"];

    [self.myTableView setSeparatorColor:mycolor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:mycolor}];

}
-(void)handleRefresh:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
    
    // sort the array with the current locatoin.
    
    NSArray *mapItems = sortArray;
    
    mapItems = [mapItems sortedArrayUsingComparator:^NSComparisonResult(MKMapItem* obj1, MKMapItem* obj2)
                {
                    float d1 = [obj1.placemark.location distanceFromLocation:self.locationManager.location];
                    float d2 = [obj2.placemark.location distanceFromLocation:self.locationManager.location];
                    if (d1 < d2)
                    {
                        return NSOrderedAscending;
                    }
                    else
                    {
                        return NSOrderedDescending;
                    }
                    
                }];
    
    transferableDivvyLocations = mapItems;
    [self.myTableView reloadData];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transferableDivvyLocations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseThisCellIdentifier"];

    DivyAddressPoint *location = transferableDivvyLocations[indexPath.row];
    cell.textLabel.text = location.stationName;
    UIColor *myColor = [UIColor pxColorWithHexValue:@"#3DB7E4"];
    cell.textLabel.textColor = myColor;

    NSInteger NumberOfBikes; NSInteger NumberofDocks;
    NumberOfBikes = [location.availableBikes intValue];
    NumberofDocks = [location.availableDocks intValue];

    int distance = roundf([location.placemark.location distanceFromLocation:self.locationManager.location]);

    NSString *detailText = [NSString stringWithFormat:@"%li Bikes, %li Docks Available, Dist <%2.2f> mi", (long)NumberOfBikes, (long)NumberofDocks, (distance/1609.34)];

    cell.detailTextLabel.textColor = myColor;
    cell.detailTextLabel.text = detailText;
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

-(void)gatherDivvyData
{

    NSString *urlString   = [NSString stringWithFormat:@"http://divvybikes.com/stations/json"];
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError != nil)
        {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"No Internet Connection"
                                                        message:@"Please try again in a few minutes"
                                                       delegate:nil //set delegate for UIAlertView
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            
            [self addParallax:av];

            [av show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        else
        {
            NSDictionary *outerContainer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
            NSArray *allDivvyLocations = outerContainer[@"stationBeanList"];

            sortArray = [NSMutableArray new];
            [sortArray removeAllObjects];

            for (NSDictionary *point in allDivvyLocations)
            {
                DivyAddressPoint *divvyLocationPoint = [DivyAddressPoint new];

                divvyLocationPoint.stationName = point[@"stationName"];
                divvyLocationPoint.address     = point[@"location"];

                divvyLocationPoint.lat         = point[@"latitude"];
                divvyLocationPoint.lng         = point[@"longitude"];


                CGFloat latitude  = (CGFloat)[divvyLocationPoint.lat floatValue];
                CGFloat longitude = (CGFloat)[divvyLocationPoint.lng floatValue];

                CLLocationCoordinate2D placeCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
                MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:placeCoordinate addressDictionary:nil];

                divvyLocationPoint.placemark = placemark;

                divvyLocationPoint.availableBikes = point[@"availableBikes"];
                divvyLocationPoint.availableDocks = point[@"availableDocks"];

                [sortArray addObject:divvyLocationPoint];

            }

            NSArray *mapItems = sortArray;

            mapItems = [mapItems sortedArrayUsingComparator:^NSComparisonResult(MKMapItem* obj1, MKMapItem* obj2)
                        {
                            float d1 = [obj1.placemark.location distanceFromLocation:self.locationManager.location];
                            float d2 = [obj2.placemark.location distanceFromLocation:self.locationManager.location];
                            if (d1 < d2)
                            {
                                return NSOrderedAscending;
                            }
                            else
                            {
                                return NSOrderedDescending;
                            }

                        }];

            transferableDivvyLocations = mapItems;
            [self.myTableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

        if ([segue.identifier isEqualToString:@"ShowAnnotationsOnMap"])
        {
            // Pass the data needed to create the annotations on the map
            AnnotationsMapViewViewController *vc = segue.destinationViewController;
            vc.navigationItem.title = @"Bike Share Map";
            vc.annotationsArray = transferableDivvyLocations;
        }
        if ([segue.identifier isEqualToString:@"ShowDetails"])
        {
            DirectionsAndMapViewController *vc = segue.destinationViewController;

            NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
            DivyAddressPoint *place = transferableDivvyLocations[indexPath.row];

            vc.divvyStationLocation = place;
            vc.navigationItem.title = @"Detail Route Information";
        }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0)
    {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }

 }

@end
