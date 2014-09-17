//
//  ConnectionManager.m
//  ChiTownBikeShare
//
//  Created by user on 9/8/14.
//  Copyright (c) 2014 Jaime Hernandez. All rights reserved.
//

#import "ConnectionManager.h"
#import "JSONParser.h"

@implementation ConnectionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//alternative implementation of a singleton using instance variable
+(instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ConnectionManager alloc] init];
        
    });
    
    return _sharedInstance;
}


/*
 * Use NSURLSession to get the data from divvybikes website. The site returns all stations in 
 * Chicago without the ability to restrict the results. Once the JSON data is return it will
 * parsed into an array of custom objects (DivvyAddressPoint) before being sent to the delegate
 * @ return void
 */
-(void)downloadStationData
{
    NSString *urlString   = [NSString stringWithFormat:@"http://divvybikes.com/stations/json"];
    NSURL *url            = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [self initializeCachingForSession:sessionConfiguration];
    sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    sessionConfiguration.timeoutIntervalForRequest = 30.0;
    sessionConfiguration.timeoutIntervalForResource = 60.0;
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *task;
    
    task  = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            
            //create a json parse and send it the JSON data to parse into custom objects
            JSONParser* parser = [[JSONParser alloc]init];
            [parser parseJSONData:data withCompletion:^(NSArray *data, NSError *error) {
                
                if (!error) {
                    
                    //safety check to make sure the delegate responds to the method - since the method is required, this
                    //is not technically necessary but is required for ALL optional methods
                    if([self.delegate respondsToSelector:@selector(didFinishDownloadingData: error: connectionManager:)])
                    {
                        [self.delegate didFinishDownloadingData:data error:nil connectionManager:self];
                    }
                }
                else { //inform the delegate if there was an issue parsing the data
                    [self.delegate didFinishDownloadingData:nil error:error connectionManager:self];


                }
                
            }];
        }
        else { // inform the delegate of there was an issue with the connection
            [self.delegate didFinishDownloadingData:nil error:error connectionManager:self];

            }
    }];
    
    [task resume];
}


/*
 * Create a custom caching session - this uses standard apple suggested code for getting
 * a cache path, and creating a cache on disk
 */
- (void)initializeCachingForSession:(NSURLSessionConfiguration*)sessionConfiguration
{
    //setup caching for image, biolerplate apple code to get path to a cache directory
    NSString *cachePath = @"/CacheDirectory";
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = myPathList.firstObject;
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
    
    //create the cache and assign to configuration object
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: fullCachePath];
    sessionConfiguration.URLCache = myCache;
    sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
}





@end
