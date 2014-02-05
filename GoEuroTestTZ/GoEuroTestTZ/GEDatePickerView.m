//
//  GEDatePickerView.m
//  GoEuroTestTZ
//
//  Created by zoltan on 2014.02.05..
//  Copyright (c) 2014 TZ. All rights reserved.
//

#import "GEDatePickerView.h"

@implementation GEDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:frame];
        
        self.datePicker.date = [NSDate date];
        self.datePicker.minimumDate = [NSDate date];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        NSLocale* usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        self.datePicker.locale = usLocale;
        self.datePicker.calendar = [usLocale objectForKey:NSLocaleCalendar];
        
        [self addSubview:self.datePicker];
    }
    return self;
}

@end