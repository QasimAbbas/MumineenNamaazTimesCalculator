//
//  NamaazCalculations.m
//  
//
//  Created by Qasim Abbas on 7/28/14.
//
//

#import "NamaazCalculations.h"
#import <CoreLocation/CoreLocation.h>


@interface NamaazCalculations ()

@end

@implementation NamaazCalculations
@synthesize time;
@synthesize lblsihoriEnd, lblFajr, lblsRise, lblAend, lblIEnd, lblMTime, lblNisf, lblZEnd, lblZTime, txtLocation, activityIndicator;

int riseHour;
int riseMinute;
int riseSecond;

CLLocationManager *locationManager;
CLLocation *currentLocation;

int fajrHour;
int fajrMinute;
int fajrSecond;

int setHour;
int setMinute;
int setSecond;

NSString * sihoriEnd;

double dayGhariHour;
double dayGhariMinute;
double dayGhari;

double nightGhariHour;
double nightGhariMinute;
double nightGhari;

NSDate *timeDate;
NSDate *sunRiseDate;
NSDate *sunSetDate;

int zawaalStartHour;
int zawaalStartMinute;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil) {
        // longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        // latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    // Reverse Geocoding
    [activityIndicator stopAnimating];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            /* Orgin
            NSString*gettingLocationString = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@",
                                              placemark.subThoroughfare, placemark.thoroughfare,
                                              placemark.locality, placemark.administrativeArea,
                                              placemark.country, placemark.postalCode];
             */
            NSString*gettingLocationString = [NSString stringWithFormat:@"%@, %@",
                                              placemark.locality,placemark.country];
            
            
            NSString *valueToSave = gettingLocationString;
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"LocationSaved"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"LocationSaved"];
            txtLocation.text = savedValue;
            
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(CLLocationCoordinate2D) getLocation{
    CLLocationManager *locationManagerOne = [[CLLocationManager alloc] init];
    locationManagerOne.delegate = self;
    locationManagerOne.desiredAccuracy = kCLLocationAccuracyBest;
    locationManagerOne.distanceFilter = kCLDistanceFilterNone;
    [locationManagerOne startUpdatingLocation];
    CLLocation *location = [locationManagerOne location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    return coordinate;
}


-(void)viewDidAppear:(BOOL)animated{
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    
    
}

- (void)viewDidLoad
{
    
   
    
    [self getCurrentLocationAUTO];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"brushed.png"]];

    
    CLLocationCoordinate2D coordinate = [self getLocation];
    
    //Testing Location Services
    [locationManager requestWhenInUseAuthorization];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
  
    
    NSLog(@"*dLatitude : %@", latitude);
    NSLog(@"*dLongitude : %@",longitude);
    
    
    
    NSTimeZone *tz = [[NSTimeZone alloc] init];
    
    EDSunriseSet *edSunriseSet = [EDSunriseSet sunrisesetWithTimezone:tz latitude: coordinate.latitude longitude: coordinate.longitude];
    
    [edSunriseSet calculateSunriseSunset:[NSDate date]];
    [edSunriseSet calculateTwilight:[NSDate date]];
    /*
     NSLog(@"%@, %@", edSunriseSet.localSunrise, edSunriseSet.localSunset);
     */
    NSDateComponents*sunrise = edSunriseSet.localSunrise;
    NSDateComponents* sunset = edSunriseSet.localSunset;
    
    NSDateComponents*fajrStart = edSunriseSet.localNauticalCivilTwilightStart;
    
    fajrHour = fajrStart.hour;
    fajrMinute = fajrStart.minute;

    
    riseHour = sunrise.hour;
    riseMinute = sunrise.minute;
    riseSecond = sunrise.second;
    
    setHour = sunset.hour;
    setMinute = sunset.minute;
    setSecond = sunset.second;
    
    double riseTotal = (riseHour * 60) + riseMinute;
    double setTotal = (setHour * 60) + setMinute;
    
    
    dayGhari = (setTotal - riseTotal)/12;
    nightGhari = 120 - dayGhari;
    //NSLog(@"%f", dayGhari);
    
    
    NSDate *timeLater = [NSDate dateWithTimeIntervalSinceNow:60*dayGhari];
    NSTimeInterval duration = [timeLater  timeIntervalSinceNow];
    NSInteger hours = floor(duration/(60*60));
    NSInteger minutes = floor((duration/60) - hours * 60);
    NSInteger seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));
    if(seconds == 59){
        minutes += 1;
    }
    dayGhariHour = hours;
    dayGhariMinute = minutes;
    
    [self sihoriTime];
    [self sunRise];
    [self Fajr];
    [self Zawaal];
    [self zohrEnd];
    [self asrEnd];
    [self Magrib];
    [self nisfUlLayl];
    
    [super viewDidLoad];


}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


-(void)getCurrentLocationAUTO{
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];

}

- (IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

-(void)sihoriTime{
    
    int sihoriHour;
    int sihoriMinute;
    
    sihoriHour = riseHour - 1;
    sihoriMinute = riseMinute - 15;
    
    /* -- Juzer's Condition -- */
    if (sihoriMinute < 0) {
        sihoriHour--;
        sihoriMinute += 60;
    }
    if (sihoriMinute >= 60) {
        sihoriHour += sihoriMinute / 60;
        sihoriMinute %= 60;
    }
    
    if (sihoriHour >= 24) {
        sihoriHour -= 24;
    }
    
    if (sihoriHour < 0) {
        sihoriHour += 24;
    }
    if(sihoriHour > 12){
        sihoriHour = sihoriHour - 12;
    }
    /* -- End of Condition -- */
    
    
    NSString *toTimeform = [[NSString alloc] initWithFormat:@"%i:%i", sihoriHour, sihoriMinute];
   // lblsihoriEnd.text = toTimeform;
    
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    if(sihoriHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimeform];
    lblsihoriEnd.text = [dateFormatter stringFromDate:ztimeConvert];
    
    
}
-(void)Fajr{
    [self sunRise];
    
    
    NSString *toTimefrom = [NSString stringWithFormat:@"%i:%i", fajrHour, fajrMinute];
    
    if(toTimefrom == NULL){
        fajrHour = riseHour - nightGhariHour;
        fajrMinute = riseMinute - nightGhariMinute;
        
        /* -- Juzer's Condition -- */
        if (zawaalStartMinute < 0) {
            zawaalStartHour--;
            zawaalStartMinute += 60;
        }
        if (zawaalStartMinute >= 60) {
            zawaalStartHour += zawaalStartMinute / 60;
            zawaalStartMinute %= 60;
        }
        
        if (zawaalStartHour >= 24) {
            zawaalStartHour -= 24;
        }
        
        if (zawaalStartHour < 0) {
            zawaalStartHour += 24;
        }
        if(zawaalStartHour > 12){
            zawaalStartHour = zawaalStartHour - 12;
        }
        /* -- End of Condition -- */
        
        toTimefrom = [NSString stringWithFormat:@"%i:%i", fajrHour, fajrMinute];

    }
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    if(fajrHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimefrom];
    lblFajr.text = [dateFormatter stringFromDate:ztimeConvert];

    
    
}
-(void)sunRise{
    
    NSString *toTimeform = [[NSString alloc] initWithFormat:@"%i:%i", riseHour, riseMinute];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    if(riseHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimeform];
    lblsRise.text = [dateFormatter stringFromDate:ztimeConvert];
    
}
-(void)Zawaal{
    
    [self sunRise];
    [self Magrib];
    
    NSDate *timeLater = [NSDate dateWithTimeIntervalSinceNow:60*dayGhari*6];
    NSTimeInterval duration = [timeLater  timeIntervalSinceNow];
    int hours = floor(duration/(60*60));
    int minutes = floor((duration/60) - hours * 60);
    int seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));
    if(seconds == 59){
        minutes += 1;
    }
    
    zawaalStartHour = hours + riseHour;
  //  NSLog(@"%i", zawaalStartHour);
    zawaalStartMinute = minutes + riseMinute;
   // NSLog(@"%i", zawaalStartMinute);
   
    
    /* -- Juzer's Condition -- */
    if (zawaalStartMinute < 0) {
        zawaalStartHour--;
        zawaalStartMinute += 60;
    }
    if (zawaalStartMinute >= 60) {
        zawaalStartHour += zawaalStartMinute / 60;
        zawaalStartMinute %= 60;
    }
    
    if (zawaalStartHour >= 24) {
        zawaalStartHour -= 24;
    }
    
    if (zawaalStartHour < 0) {
        zawaalStartHour += 24;
    }
    if(zawaalStartHour > 12){
        zawaalStartHour = zawaalStartHour - 12;
    }
    /* -- End of Condition -- */
    
    NSString *toTimefrom = [NSString stringWithFormat:@"%i:%i", zawaalStartHour, zawaalStartMinute];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    
    if(zawaalStartHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimefrom];
    lblZTime.text = [dateFormatter stringFromDate:ztimeConvert];
    
}
-(void)zohrEnd{
    [self Zawaal];
    
    int zEndHour;
    int zEndMinute;
    
    NSDate *timeLater = [NSDate dateWithTimeIntervalSinceNow:60*dayGhari*3];
    NSTimeInterval duration = [timeLater  timeIntervalSinceNow];
    int hours = floor(duration/(60*60));
    int minutes = floor((duration/60) - hours * 60);
    int seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));
    if(seconds == 59){
        minutes += 1;
    }
    
    zEndHour = hours + zawaalStartHour;
    //  NSLog(@"%i", zawaalStartHour);
    zEndMinute = minutes + zawaalStartMinute;
    // NSLog(@"%i", zawaalStartMinute);
    
    
    /* -- Juzer's Condition -- */
    if (zEndMinute < 0) {
        zEndHour--;
        zEndMinute += 60;
    }
    if (zEndMinute >= 60) {
        zawaalStartHour += zEndMinute / 60;
        zEndMinute %= 60;
    }
    
    if (zEndHour >= 24) {
        zEndHour -= 24;
    }
    
    if (zEndHour < 0) {
        zEndHour += 24;
    }
    if(zEndHour > 12){
        zEndHour = zEndHour - 12;
    }
    NSString *toTimefrom = [NSString stringWithFormat:@"%i:%i", zEndHour, zEndMinute];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    
    if(zEndHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimefrom];
    lblZEnd.text = [dateFormatter stringFromDate:ztimeConvert];
    
}
-(void)asrEnd{
    [self Zawaal];
    int aEndHour;
    int aEndMinute;
    
    NSDate *timeLater = [NSDate dateWithTimeIntervalSinceNow:60*dayGhari*4];
    NSTimeInterval duration = [timeLater  timeIntervalSinceNow];
    int hours = floor(duration/(60*60));
    int minutes = floor((duration/60) - hours * 60);
    int seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));
    if(seconds == 59){
        minutes += 1;
    }
    
    aEndHour = hours + zawaalStartHour;
    //  NSLog(@"%i", zawaalStartHour);
    aEndMinute = minutes + zawaalStartMinute;
    // NSLog(@"%i", zawaalStartMinute);
    
    
    /* -- Juzer's Condition -- */
    if (aEndMinute < 0) {
        aEndHour--;
        aEndMinute += 60;
    }
    if (aEndMinute >= 60) {
        aEndHour += aEndMinute / 60;
        aEndMinute %= 60;
    }
    
    if (aEndHour >= 24) {
        aEndHour -= 24;
    }
    
    if (aEndHour < 0) {
        aEndHour += 24;
    }
    if(aEndHour > 12){
        aEndHour = aEndHour - 12;
    }
    
    /* -- Format Time -- */
    NSString *toTimefrom = [NSString stringWithFormat:@"%i:%i", aEndHour, aEndMinute];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    
    if(aEndHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    NSDate*atimeConvert = [dateFormatter dateFromString:toTimefrom];
    lblAend.text = [dateFormatter stringFromDate:atimeConvert];
    
}
-(void)Magrib{
    
    
    
    NSString *toTimeform = [[NSString alloc] initWithFormat:@"%d:%d", setHour, setMinute];
    NSDateFormatter *calcSetFormatter = [[NSDateFormatter alloc] init];
    calcSetFormatter.dateFormat = @"hh:mm";
    sunSetDate = [calcSetFormatter dateFromString:toTimeform];
    
    if(setHour > 12){
        setHour = setHour - 12;
    }
    toTimeform = [[NSString alloc] initWithFormat:@"%i:%i", setHour, setMinute];
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    if(setHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    
    NSDate*ztimeConvert = [dateFormatter dateFromString:toTimeform];
    lblMTime.text = [dateFormatter stringFromDate:ztimeConvert];
    
    
}
-(void)nisfUlLayl{
    int nisfStartHour;
    int nisfStartMinute;
    int nisfEndHour;
    int nisfEndMinute;
    
    nisfStartHour = zawaalStartHour;
    nisfStartMinute = zawaalStartMinute;
    
    NSString *toTimeform = [[NSString alloc] initWithFormat:@"%d:%d", nisfStartHour, nisfStartMinute];
    NSDateFormatter *calcSetFormatter = [[NSDateFormatter alloc] init];
    
    if(nisfStartHour >= 10){
        calcSetFormatter.dateFormat = @"hh:mm";
    }else{
        calcSetFormatter.dateFormat = @"h:mm";
    }
    NSDate* nisf = [calcSetFormatter dateFromString:toTimeform];
    lblIEnd.text = [calcSetFormatter stringFromDate:nisf];

    
    
    NSDate *timeLater = [NSDate dateWithTimeIntervalSinceNow:60*nightGhari];
    NSTimeInterval duration = [timeLater  timeIntervalSinceNow];
    NSInteger hours = floor(duration/(60*60));
    NSInteger minutes = floor((duration/60) - hours * 60);
    NSInteger seconds = floor(duration - (minutes * 60) - (hours * 60 * 60));
    if(seconds == 59){
        minutes += 1;
    }
    nisfEndHour = nisfStartHour + hours;
    nisfEndMinute = nisfStartMinute + minutes;
    
    /* -- Juzer's Condition -- */
    if (nisfEndMinute < 0) {
        nisfEndHour--;
        nisfEndMinute += 60;
    }
    if (nisfEndMinute >= 60) {
        nisfEndHour += nisfEndMinute / 60;
        nisfEndMinute %= 60;
    }
    
    if (nisfEndHour >= 24) {
        nisfEndHour -= 24;
    }
    
    if (nisfEndHour < 0) {
        nisfEndHour += 24;
    }
    if(nisfEndHour > 12){
        nisfEndHour = nisfEndHour - 12;
    }
    
    /* -- Format Time -- */
    NSString *toTimefrom = [NSString stringWithFormat:@"%i:%i", nisfEndHour, nisfEndMinute];
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc ]init];
    
    if(nisfEndHour >= 10){
        dateFormatter.dateFormat = @"hh:mm";
    }else{
        dateFormatter.dateFormat = @"h:mm";
    }
    NSDate*atimeConvert = [dateFormatter dateFromString:toTimefrom];
    lblNisf.text = [dateFormatter stringFromDate:atimeConvert];

    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
