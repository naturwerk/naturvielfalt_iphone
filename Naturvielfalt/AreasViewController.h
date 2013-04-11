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
#import "DDAnnotation.h"

typedef enum DrawMode{
    POINT = 1,
    LINE = 2,
    LINE_FH = 3,
    POLYGON = 4,
    POLYGON_FH = 5,
}DrawMode;
 
@interface AreasViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate> {
    IBOutlet MKMapView *mapView;
    MKOverlayView *overlayView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    MKMapPoint *points;
    MKPolygon *polygon;
    MKPolyline *line;
    UIBezierPath *currentPath;
    NSString *annotationViewID;
    NSString *pinAnnotationViewID;
    DDAnnotation *pinAnnotation;
    DDAnnotation *startPoint;
    MKPinAnnotationView *pinAnnotationView;
    MKAnnotationView *annotationView;
    MKPolylineView *lineView;
    MKPolygonView *polygonView;
    NSMutableArray *longitudeArray;
    NSMutableArray *latitudeArray;
    DrawMode currentDrawMode;
    UIActionSheet *modeOptions;
    
    BOOL review;
    BOOL undo;
    BOOL shouldAdjustZoom;
}

@property (nonatomic) IBOutlet UIBarButtonItem * cancel;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (weak, nonatomic) IBOutlet UIImageView *hairlinecross;

- (IBAction)setPoint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)showModeOptions:(id)sender;
- (IBAction)relocate:(id)sender;
- (void) prepareData;


@end
