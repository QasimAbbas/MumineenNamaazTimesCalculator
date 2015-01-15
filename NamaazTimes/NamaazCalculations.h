//
//  NamaazCalculations.h
//  
//
//  Created by Qasim Abbas on 7/28/14.
//
//

#import <UIKit/UIKit.h>
#import "EDSunriseSet.h"
#import <CoreLocation/CoreLocation.h>


@interface NamaazCalculations : UITableViewController<CLLocationManagerDelegate>{
    
    EDSunriseSet *time;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UITextView *txtLocation;

@property (strong, nonatomic) IBOutlet UILabel *lblsihoriEnd;
@property (strong, nonatomic) IBOutlet UILabel *lblFajr;
@property (strong, nonatomic) IBOutlet UILabel *lblsRise;
@property (strong, nonatomic) IBOutlet UILabel *lblZTime;
@property (strong, nonatomic) IBOutlet UILabel *lblZEnd;
@property (strong, nonatomic) IBOutlet UILabel *lblAend;

@property (strong, nonatomic) IBOutlet UILabel *lblMTime;
@property (strong, nonatomic) IBOutlet UILabel *lblIEnd;
@property (strong, nonatomic) IBOutlet UILabel *lblNisf;
- (IBAction)getCurrentLocation:(id)sender;



@property (nonatomic, retain)EDSunriseSet *time;

@end
