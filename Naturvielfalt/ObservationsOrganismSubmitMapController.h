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

@interface ObservationsOrganismSubmitMapController : UIViewController {
    IBOutlet MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    Observation *observation;
    DDAnnotation *annotation;
    
    BOOL review;
    BOOL shouldAdjustZoom;
    BOOL pinMoved;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) DDAnnotation *annotation;
@property (nonatomic, assign) BOOL review;
@property (nonatomic, assign) BOOL shouldAdjustZoom;
@property (nonatomic, assign) BOOL pinMoved;


- (DDAnnotation *) adaptPinSubtitle:(DDAnnotation *)annotation withCoordinate:(CLLocationCoordinate2D)theCoordinate;
- (void) returnBack;
- (void) relocate;


@end
