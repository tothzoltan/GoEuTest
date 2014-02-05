//
//  GEPredefinedLocation.m
//  GoEuroTestTZ
//
//  Created by zoltan on 2014.02.05..
//  Copyright (c) 2014 TZ. All rights reserved.
//

#import "GEPredefinedLocation.h"

#import "GEPredefinedLocation.h"

NSString* const kName = @"name";
NSString* const kGeoPosition = @"geo_position";
NSString* const kLatitude = @"latitude";
NSString* const kLongitude = @"longitude";

@implementation GEPredefinedLocation
@synthesize name = name_;
@synthesize location = location_;


- (id)initWithPredefinedLocationDic:(NSDictionary*)predefinedLocationDic
{
    self = [super init];
    if (self != nil)
    {
        if (nil != predefinedLocationDic)
        {
            for (NSString *key in predefinedLocationDic) {
                if ([key isEqualToString:kName]) {
                    self.name = [predefinedLocationDic valueForKey:key];
                }
                else if ([key isEqualToString:kGeoPosition])
                {
                    NSDictionary *geoPosition = [predefinedLocationDic valueForKey:key];
                    if (geoPosition != nil)
                    {
                        CLLocationDegrees lat = [[geoPosition valueForKey:kLatitude] doubleValue];
                        CLLocationDegrees lon = [[geoPosition valueForKey:kLongitude] doubleValue];
                        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                    }
                }
            }
        }
    }
    return self;
}

- (id)initWithName:(NSString*)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    self = [super init];
    if (self != nil)
    {
        self.name = name;
        self.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    return self;
}

@end
