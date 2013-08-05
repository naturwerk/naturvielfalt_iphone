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
#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"
#import "CustomLineView.h"
#import "CustomPolygonView.h"
#import "PersistenceManager.h"
#import "MBProgressHUD.h"

@class CustomAnnotationView;
@interface AreasViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UISearchBarDelegate, MBProgressHUDDelegate> {
    PersistenceManager *persistenceManager;

    MKOverlayView *overlayView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    MKMapPoint *points;
    UIBezierPath *currentPath;
    CustomAnnotation *startPoint;
    CustomAnnotation *pinAnnotation;
    CustomAnnotation *customAnnotation;
    CustomAnnotationView *customAnnotationView;
    MKPolyline *customLine;
    CustomLineView *customLineView;
    MKPolygon *customPolygon;
    CustomPolygonView *customPolygonView;
    NSMutableArray *longitudeArray;
    NSMutableArray *latitudeArray;
    NSMutableArray *locationPoints;
    DrawMode currentDrawMode;
    UIActionSheet *modeOptions;
    MBProgressHUD *loadingHUD;
    Area *area;
    BOOL review;
    BOOL undo;
    BOOL shouldAdjustZoom;
    
    IBOutlet MKMapView *mapView;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *saveButton;
    IBOutlet UIButton *undoButton;
    IBOutlet UIButton *setButton;
    IBOutlet UIButton *gpsButton;
    IBOutlet UIButton *modeButton;
    IBOutlet UIImageView *hairlinecross;
    IBOutlet UISearchBar *searchBar;
    
    //Custom Annotations and Shapes (Line, Polygon)
    NSMutableArray *annotationsArray;
    NSMutableArray *overlaysArray;
    IBOutlet UISegmentedControl *segmentedControl;
}
@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet UIBarButtonItem * cancelButton;
@property (nonatomic) IBOutlet UIBarButtonItem * saveButton;
@property (nonatomic) IBOutlet UIButton *undoButton;
@property (nonatomic) IBOutlet UIButton *setButton;
@property (nonatomic) IBOutlet UIButton *modeButton;
@property (nonatomic) IBOutlet UIButton *gpsButton;
@property (nonatomic) IBOutlet UIImageView *hairlinecross;
@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UISearchBar *searchBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil area:(Area*)a;
- (IBAction)setPoint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)showModeOptions:(id)sender;
- (IBAction)relocate:(id)sender;
- (void) showPersistedAppearance;

- (void) setAnnotationInEditMode:(CustomAnnotation*)annotation;
- (IBAction)segmentChanged:(id)sender;


@end
