//
//  ViewController.h
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/6/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic) NSArray *transferableDivvyLocations;

@end
