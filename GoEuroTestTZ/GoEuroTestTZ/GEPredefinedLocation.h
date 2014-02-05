//
//  GEPredefinedLocation.h
//  GoEuroTestTZ
//
//  Created by zoltan on 2014.02.05..
//  Copyright (c) 2014 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GEPredefinedLocation : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) CLLocation* location;

- (id)initWithPredefinedLocationDic:(NSDictionary*)predefinedLocationDic;


@end
