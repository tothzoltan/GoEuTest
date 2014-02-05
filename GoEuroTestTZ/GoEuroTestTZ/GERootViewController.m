//
//  GERootViewController.m
//  GoEuroTestTZ
//
//  Created by zoltan on 2014.02.05..
//  Copyright (c) 2014 TZ. All rights reserved.
//

#import "GERootViewController.h"
#import "GEPredefinedLocation.h"
#import "GEDatePickerView.h"


CGFloat const kTextFieldHeight = 35;
CGFloat const kInset = 10;
CGFloat const kLocationTipHeight = 65;
CGFloat const kDatePickerHeight = 60;
CGFloat const kButtonHeight = 40;
NSTimeInterval const kTenMinutesAgo = -1 * 10 * 60;
NSTimeInterval const kADayAgo = -24 * 60 * 60;


@interface GERootViewController ()

// activeField tells you which textField is being edited right now
@property (nonatomic, weak) UITextField* activeField;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* location;


@property (nonatomic, strong) UITableView* locationTipTableView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) GEDatePickerView* datePickerView;
@property (nonatomic, strong) UIButton* dateChooserButton;

@property (nonatomic, strong) UIButton* searchButton;

@property (nonatomic, strong) NSArray* locationTipArray;

@end



@implementation GERootViewController

@synthesize fromField = _fromField;
@synthesize destinationField = _destinationField;
@synthesize locationTipTableView = _locationTipTableView;
@synthesize datePickerView = _datePickerView;
@synthesize dateChooserButton = _dateChooserButton;
@synthesize activeField = _activeField;
@synthesize locationManager = _locationManager;
@synthesize location = _location;
@synthesize locationTipArray = _locationTipArray;
@synthesize activityIndicator = _activityIndicator;


#pragma mark UIViewController methods

- (void)loadView
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *aView = [[UIView alloc] initWithFrame:screenBounds];
    
    CGFloat topInset = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        topInset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    
    aView.backgroundColor = [UIColor whiteColor];
    
    self.fromField = [[UITextField alloc] initWithFrame:CGRectMake(0, kInset + topInset, aView.frame.size.width, kTextFieldHeight)];
    self.fromField.placeholder = @"Departure";
    self.fromField.delegate = self;
    self.fromField.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.fromField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.fromField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [aView addSubview:self.fromField];
    
    self.destinationField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.fromField.frame.origin.y + self.fromField.frame.size.height + kLocationTipHeight, aView.frame.size.width, kTextFieldHeight)];
    self.destinationField.placeholder = @"Destination";
    self.destinationField.autocorrectionType = UITextAutocapitalizationTypeNone;
    self.destinationField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.destinationField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.destinationField.delegate = self;
    [aView addSubview:self.destinationField];
    
    self.locationTipTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, aView.frame.size.width, kLocationTipHeight) style:UITableViewStylePlain];
    self.locationTipTableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.1];
    self.locationTipTableView.dataSource = self;
    self.locationTipTableView.delegate = self;
    self.locationTipTableView.hidden = YES;
    [aView addSubview:self.locationTipTableView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [aView addSubview:self.activityIndicator];
    
    self.dateChooserButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.dateChooserButton.frame = CGRectMake(0, self.destinationField.frame.origin.y + self.destinationField.frame.size.height + kLocationTipHeight, aView.frame.size.width, kButtonHeight);
    [self.dateChooserButton setTitle:@"Choose a date!" forState:UIControlStateNormal];
    [self.dateChooserButton addTarget:self action:@selector(showDatePickerView) forControlEvents:UIControlEventTouchDown];
    [aView addSubview:self.dateChooserButton];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.searchButton.frame = CGRectMake(0, self.dateChooserButton.frame.origin.y + self.dateChooserButton.frame.size.height, aView.frame.size.width, kButtonHeight);
    [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
    self.searchButton.hidden = YES;
    [self.searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchDown];
    [aView addSubview:self.searchButton];
    
    self.view = aView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GoEuro";
    
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // get the user's location, if possible. By this time, we are going to need it anyway
    if ([CLLocationManager locationServicesEnabled] &&
        (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) ||
          [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined))
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark miscellaneous

- (void)setupVisibilityForSearchButton
{
    if (nil != self.fromField.text && self.fromField.text.length > 0 &&
        nil != self.destinationField.text && self.destinationField.text.length > 0 &&
        nil != self.chosenDate)
    {
        self.searchButton.hidden = NO;
    }
    else
    {
        self.searchButton.hidden = YES;
    }
}


#pragma mark date picker

- (GEDatePickerView*)datePickerView
{
    if (nil == _datePickerView)
    {
        _datePickerView = [[GEDatePickerView alloc] initWithFrame:self.view.frame];
        
        if (nil != self.chosenDate)
        {
            [_datePickerView.datePicker setDate:self.chosenDate animated:YES];
        }
        else
        {
            [_datePickerView.datePicker setDate:[NSDate date] animated:YES];
        }
    }
    
    return _datePickerView;
}

- (void)showDatePickerView
{
    if (nil != self.chosenDate)
    {
        [self.datePickerView.datePicker setDate:self.chosenDate animated:YES];
    }
    else
    {
        [self.datePickerView.datePicker setDate:[NSDate date] animated:YES];
    }
    
    [self.view addSubview:self.datePickerView];
    
    self.datePickerView.alpha = 0.0;
    
    CGRect modalFrame = self.datePickerView.frame;
    
    modalFrame.origin.y = self.view.frame.size.height;
    self.datePickerView.frame = modalFrame;
    
    
    [UIView animateWithDuration:0.5
                     animations:^(void)
     {
         CGRect frame = self.datePickerView.frame;
         CGFloat top = 0;
         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
         {
             top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
         }
         
         frame.origin.y = top;
         
         self.datePickerView.frame = frame;
         self.datePickerView.alpha = 1.0;
     }
                     completion:^(BOOL finished) {
                         UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                                        style:UIBarButtonItemStyleBordered
                                                                                       target:self
                                                                                       action:@selector(hideDatePicker)];
                         UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                         style:UIBarButtonItemStyleBordered
                                                                                        target:self
                                                                                        action:@selector(doneDatePicker)];
                         self.navigationItem.leftBarButtonItem = leftButton;
                         self.navigationItem.rightBarButtonItem = rightButton;
                     }];
}

- (void)hideDatePicker
{
    [UIView animateWithDuration:0.5
                     animations:^(void)
     {
         self.datePickerView.alpha = 0.0;
         CGRect frame = self.datePickerView.frame;
         frame.origin.y = self.view.frame.size.height;
         self.datePickerView.frame = frame;
     }
                     completion:^(BOOL finished)
     {
         self.navigationItem.leftBarButtonItem = nil;
         self.navigationItem.rightBarButtonItem = nil;
         self.datePickerView = nil;
     }];
}

- (void)doneDatePicker
{
    self.chosenDate = self.datePickerView.datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    [self.dateChooserButton setTitle:[dateFormatter stringFromDate:self.chosenDate] forState:UIControlStateNormal];
    
    [self hideDatePicker];
    
    [self setupVisibilityForSearchButton];
}


#pragma mark UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (! [string isEqualToString:@"\n"])
    {
        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] length] != 0)
        {
            [self searchForPrefix:[textField.text stringByReplacingCharactersInRange:range withString:string]];
        }
        else
        {
            [self.activityIndicator stopAnimating];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    
    self.locationTipTableView.hidden = YES;
    self.activityIndicator.center = CGPointMake(self.activeField.frame.origin.x + self.activeField.frame.size.width / 2, self.activeField.frame.origin.y + self.activeField.frame.size.height / 2);
    
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.activeField == textField)
    {
        self.activeField = nil;
        [self.activityIndicator stopAnimating];
        self.locationTipTableView.hidden = YES;
        
        [self setupVisibilityForSearchButton];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.activityIndicator stopAnimating];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark Core Location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    if ([location.timestamp timeIntervalSinceNow] > kTenMinutesAgo)
    {
        [self.locationManager stopUpdatingLocation];
        self.location = location;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error");
    [self.locationManager stopUpdatingLocation];
}


#pragma mark networking

- (void)searchForPrefix:(NSString*)prefix
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.goeuro.com/api/v1/suggest/position/en/name/%@", prefix];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    
    [self.activityIndicator startAnimating];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error)
                               {
                                   NSLog(@"Failed to fetch search results for prefix:%@", prefix);
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                       [self.activityIndicator stopAnimating];
                                   }];
                               }
                               else
                               {
                                   [self receivedSearchJSON:data forPrefix:prefix];
                               }
                           }];
}

- (void)receivedSearchJSON:(NSData *)data forPrefix:(NSString *)prefix
{
    if ((nil != self.activeField) && ([self.activeField.text isEqualToString:prefix]))
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self.activityIndicator stopAnimating];
        }];
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        
        if (localError != nil) {
            NSLog(@"Error parsing JSON.");
            return;
        }
        
        NSMutableArray *predefinedLocations = [[NSMutableArray alloc] init];
        
        NSArray *results = [parsedObject valueForKey:@"results"];
        
        if (nil != results)
        {
            for (NSDictionary *predefinedLocationDic in results) {
                GEPredefinedLocation *predefinedLocation = [[GEPredefinedLocation alloc] initWithPredefinedLocationDic:predefinedLocationDic];
                
                if (nil == predefinedLocation || predefinedLocation.location == nil || predefinedLocation.name == nil)
                {
                    NSLog(@"Failed to parse a name or a geolocation");
                    return;
                }
                
                [predefinedLocations addObject:predefinedLocation];
            }
            
            // Sort the suggestions if possible
            if (self.location)
            {
                [predefinedLocations sortUsingComparator: ^(id a, id b) {
                    CLLocationDistance first = [((GEPredefinedLocation*)a).location distanceFromLocation:self.location];
                    CLLocationDistance second = [((GEPredefinedLocation*)b).location distanceFromLocation:self.location];
                    if (first < second)
                    {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    else if (first > second)
                    {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    else
                    {
                        return (NSComparisonResult)NSOrderedSame;
                    }
                }];
            }
            
            NSMutableArray* locationTips = [NSMutableArray arrayWithCapacity:[predefinedLocations count]];
            for (GEPredefinedLocation* location in predefinedLocations)
            {
                [locationTips addObject:location.name];
            }
            
            if (nil != locationTips && [locationTips count] > 0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [self showTips:locationTips forPrefix:prefix];
                }];
            }
        }
    }
}

#pragma mark location tips

- (void)showTips:(NSArray*)locationTips forPrefix:prefix
{
    if (nil != self.activeField)
    {
        if ([self.activeField.text isEqualToString:prefix])
        {
            self.locationTipArray = locationTips;
            
            [self.locationTipTableView reloadData];
            
            self.locationTipTableView.frame = CGRectMake(self.locationTipTableView.frame.origin.x,
                                                         self.activeField.frame.origin.y + self.activeField.frame.size.height,
                                                         self.locationTipTableView.frame.size.width,
                                                         self.locationTipTableView.frame.size.height);
            self.locationTipTableView.hidden = NO;
        }
    }
}

- (void)search
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Search is not yet implemented" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

#pragma mark TableView's dataSource and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != self.locationTipArray)
    {
        return [self.locationTipArray count];
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"locationTipCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
    cell.textLabel.text = [self.locationTipArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.activeField.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self.activeField resignFirstResponder];
    tableView.hidden = YES;
}

@end
