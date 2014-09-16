//
//  AnnotationsMapViewViewController.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/7/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKMapView;

@protocol AnnotationsMapViewViewControllerDelegate;

@interface AnnotationsMapViewViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *annotationsMapView; // MKMapView

@property (strong, nonatomic) NSArray *annotationsArray;


@end
