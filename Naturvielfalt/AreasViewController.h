//
//  AreasViewController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.04.13.
//  Copyright (c) 2013 Naturwerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
 
@interface AreasViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    IBOutlet MKMapView *mapView;
    MKOverlayView *overlayView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    MKMapPoint *points;
    MKPolygon *polygon;
    MKPolygonView *polygonView;
    NSMutableArray *longitudeArray;
    NSMutableArray *latitudeArray;
    
    BOOL review;
    BOOL shouldAdjustZoom;
}

- (IBAction)setPoint:(id)sender;
- (IBAction)redo:(id)sender;




@end
