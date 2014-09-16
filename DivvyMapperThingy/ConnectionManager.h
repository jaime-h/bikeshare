//
//  ConnectionManager.h
//  ChiTownBikeShare
//
//  Created by user on 9/8/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionManagerDelegate;


@interface ConnectionManager : NSObject

//class method
+(ConnectionManager*)sharedInstance;
@property(nonatomic, weak) id < ConnectionManagerDelegate > delegate;

-(void)downloadStationData;

@end

@protocol ConnectionManagerDelegate <NSObject>

@required
-(void)didFinishDownloadingData:(NSArray*)data error:(NSError*)error connectionManager:(ConnectionManager*)manager;

@end
