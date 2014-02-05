//
//  GERootViewController.h
//  GoEuroTestTZ
//
//  Created by zoltan on 2014.02.05..
//  Copyright (c) 2014 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GERootViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField* fromField;
@property (nonatomic, strong) UITextField* destinationField;

@property (nonatomic, strong) NSDate* chosenDate;



@end
