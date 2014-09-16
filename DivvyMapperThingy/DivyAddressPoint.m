//
//  DivyAddressPoint.m
//  DivvyMapperThingy
//
//  Created by Jaime Hernandez on 5/6/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "DivyAddressPoint.h"

@implementation DivyAddressPoint

- (CLLocationCoordinate2D)location
{
    return _location = CLLocationCoordinate2DMake([self.lat floatValue], [self.lng floatValue]);
}

@end
