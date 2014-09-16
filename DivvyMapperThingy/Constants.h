//
//  Constants.h
//  ChiTownBikeShare
//
//  Created by user on 9/8/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

//a better way to define constants for colors - notice no semi-colons at end of line
//this is called a marco, it could be any executable code or method call as shown here
//if these colors are used everywhere then it makes sense to put them in a Constants.h file
#define RED  [UIColor colorWithRed:0.884739 green:0.0 blue:0.0819708 alpha:1.0]
#define AMBER [UIColor colorWithRed:0.947441 green:0.740463 blue:0.0295548 alpha:1.0]
#define GREEN  [UIColor colorWithRed:0.175641 green:0.893318 blue:0.15646 alpha:1.0]
#define COLOR [UIColor pxColorWithHexValue:@"#3DB7E4"]

//define a custom structore to hold the map min and max points
typedef struct MapViewRect {
    CGPoint minPoint;
    CGPoint maxPoint;
}MapViewRect;


@end
