//
//  ObservationsOrganismSubmitMapController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 17.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Observation.h"
#import "DDAnnotation.h"

@interface ObservationsOrganismSubmitMapController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate> {
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *setButton;
    IBOutlet UISearchBar *searchBar;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSInteger currentAccuracy;
    Observation *observation;
    DDAnnotation *annotation;
    
    BOOL review;
    BOOL shouldAdjustZoom;
    BOOL pinMoved;
    
    //Search feature
    NSDate *lastPetition;
}

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) Observation *observation;
@property (nonatomic) DDAnnotation *annotation;
@property (nonatomic, assign) BOOL review;
@property (nonatomic, assign) BOOL shouldAdjustZoom;
@property (nonatomic, assign) BOOL pinMoved;
@property (nonatomic) IBOutlet UIButton *setButton;
@property (nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) NSDate *lastPetition;


- (IBAction)setPin:(id)sender;
- (IBAction)relocate:(id)sender;

- (DDAnnotation *) adaptPinSubtitle:(CLLocationCoordinate2D)theCoordinate;
- (void) returnBack;


@end
