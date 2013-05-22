//
//  ObservationsOrganismSubmitMapController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 17.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismSubmitMapController.h"
#import "Observation.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "ObservationsOrganismSubmitController.h"
#import "SwissCoordinates.h"

#define pWidth 5
#define pAlpha 0.3

@implementation ObservationsOrganismSubmitMapController
@synthesize mapView, currentLocation, observation, annotation, review, shouldAdjustZoom, pinMoved, locationManager, setButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(returnBack)];
    
    self.navigationItem.rightBarButtonItem = backButton;
    
    observation = [[[Observation alloc] init] getObservation];
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    
    // RELOCATE button
    /*UIBarButtonItem *relocate = [[UIBarButtonItem alloc] initWithTitle:@"GPS"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(relocate)];
    
    self.navigationItem.leftBarButtonItem = relocate;*/
    
    /*if(review || observation.locationLocked) {

        MKCoordinateRegion mapRegion = mapView.region;
        mapRegion.center = observation.location.coordinate;
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005; 
        mapRegion.span = span;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        // Update coordinate
        [annotation setCoordinate:observation.location.coordinate];
        
        self.mapView.showsUserLocation = NO;  
        
    } else {
        
        if ([CLLocationManager locationServicesEnabled]) {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 1000.0f;
            [locationManager startUpdatingLocation];
        }
        self.mapView.showsUserLocation = YES;        
    }*/
    
    
    // Set delegation and show users current position
    mapView.delegate = self;

    // Register event for handling zooming in on users current position
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
    
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"observationLocalization", nil);
    self.navigationItem.title = title;
    
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.longitude = observation.location.coordinate.longitude;
    theCoordinate.latitude = observation.location.coordinate.latitude;
	
	annotation = [[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil];
	annotation.title = [NSString stringWithFormat:@"%@", [observation.organism getNameDe]];
    
    shouldAdjustZoom = YES;
    
    // Calculate swiss coordinates
    annotation = [self adaptPinSubtitle: theCoordinate];
    
    pinMoved = false;
    [setButton setTitle:NSLocalizedString(@"observationAdd", nil) forState:UIControlStateNormal];
    
    self.mapView.mapType = MKMapTypeHybrid;
	[self.mapView addAnnotation:annotation];
    [self loadArea];
}

- (void) viewWillAppear:(BOOL)animated {
    currentLocation = observation.location;
    currentAccuracy = observation.accuracy;
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite;break;}
        case 2:{mapView.mapType = MKMapTypeHybrid;break;}
        case 3:{mapView.mapType = MKMapTypeStandard;break;}
    }
    
    [self zoomToAnnotation];
    [self loadArea];
}

- (void) loadArea {
    if (observation.inventory) {
        NSMutableArray *locationPoints = [[NSMutableArray alloc] initWithArray:observation.inventory.area.locationPoints];
        
        MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
        
        for (int index = 0; index < locationPoints.count; index++) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
            coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        
        switch (observation.inventory.area.typeOfArea) {
            case POINT:
            {
                /*CLLocationCoordinate2D coordinate;
                coordinate.longitude = ((LocationPoint*)locationPoints[0]).longitude;
                coordinate.latitude = ((LocationPoint*)locationPoints[0]).latitude;
                pinAnnotation = [[CustomAnnotation alloc]initWithWithCoordinate:coordinate type:currentDrawMode area:area];
                pinAnnotation.persisted = YES;
                pinAnnotation.area = area;
                [self drawPoint];*/
                break;
            }
            case LINE:
            {
                MKPolyline *line = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                [mapView addOverlay:line];
                break;
            }
            case POLYGON:
            {
                if (locationPoints.count > 2) {
                    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:locationPoints.count];
                    [mapView addOverlay:polygon];

                } else {
                    MKPolyline *line = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                    [mapView addOverlay:line];
                }
            }
        }
    }
}

- (IBAction)setPin:(id)sender {
    // Sets the pin in the middle of the hairline cross
    MKCoordinateRegion mapRegion = mapView.region;
    NSLog(@"New coordinates: longitude - %g latitude - %g", mapRegion.center.longitude, mapRegion.center.latitude);
    
    [annotation setCoordinate:mapRegion.center];
    
    // Get annotation and update the observation
	DDAnnotation *anno = annotation;
    CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(anno.coordinate.latitude, anno.coordinate.longitude)
                                                            altitude:observation.location.altitude
                                                  horizontalAccuracy:observation.location.horizontalAccuracy
                                                    verticalAccuracy:observation.location.verticalAccuracy
                                                           timestamp:[NSDate date]];
    
    currentLocation = newLocation;
    observation.locationLocked = YES;
    currentAccuracy = 0;

    pinMoved = true;
    
    // Calculate swiss coordinates
    annotation = [self adaptPinSubtitle:annotation.coordinate];
}

- (DDAnnotation *) adaptPinSubtitle:(CLLocationCoordinate2D)theCoordinate
{
    NSLog(@"adaptPinSubtitle");
    // Calculate swiss coordinates
    SwissCoordinates *swissCoordinates = [[SwissCoordinates alloc] init];
    NSMutableArray *arrayCoordinates = [swissCoordinates calculate:theCoordinate.longitude latitude:theCoordinate.latitude];
    
    annotation.subtitle = [NSString	stringWithFormat:@"CH03 (%.0f, %.0f) \n WGS84 (%.3f, %.3f)", [[arrayCoordinates objectAtIndex:0] doubleValue], [[arrayCoordinates objectAtIndex:1] doubleValue], theCoordinate.longitude, theCoordinate.latitude];
    
    return annotation;
}

- (IBAction)relocate:(id)sender {
    //self.navigationItem.leftBarButtonItem.action = @selector(GPSrelocate);
    //self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"observationRelocate", nil);
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005;
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
        
        /*NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];*/
    }
    
    self.mapView.showsUserLocation = YES;
}
/*
- (void) GPSrelocate{
    NSLog(@"GPSrelocate");
    [locationManager stopUpdatingLocation];
    
    review = false;
    observation.locationLocked = false;
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    self.mapView.showsUserLocation = YES;
    
}*/
- (void) zoomToAnnotation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = annotation.coordinate.latitude;
    location.longitude = annotation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [mapView setRegion:region animated:YES];
}

- (void) returnBack 
{
    observation.locationLocked = true;
    observation.accuracy = currentAccuracy;
    observation.location = currentLocation;
    // Change view back to submitController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                      initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Set the current displayed organism
    organismSubmitController.organism = observation.organism;
    
    
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
}


// Listen to change in the userLocation
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
    NSLog(@"observeValueForKeyPath");
    if(shouldAdjustZoom) {   
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;  
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005; 
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
        
        shouldAdjustZoom = false;
    }

    /*if(!observation.locationLocked){
        [annotation setCoordinate:self.mapView.userLocation.coordinate];
        NSLog( @"set the pin to new pos");
    }*/
}

- (void)viewDidUnload
{
    [self setSetButton:nil];
    [super viewDidUnload];
}


- (void) dealloc 
{
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark
#pragma mark CLLocationManagerDelegate Methods
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"locationManager didUpdateToLocation");
     if(!observation.locationLocked && !review) {
        // update observation value
        observation.location = newLocation;
        observation.accuracy = (int)newLocation.horizontalAccuracy;
        [annotation setCoordinate:newLocation.coordinate];
        
        MKCoordinateRegion mapRegion = mapView.region;
        mapRegion.center = newLocation.coordinate;
        self.mapView.region = mapRegion;    
        NSLog( @"set new location from locationmanager; accuracy: %d", observation.accuracy);
    }
    
    
}

- (void) viewDidDisappear:(BOOL)animated 
{
    [locationManager stopUpdatingHeading];
}

- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error
{
    [manager stopUpdatingLocation];
    NSLog(@"error%@",error);
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"alertMessageNetwork", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"alertMessageGPS", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"alertMessageUnknownError", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
    }
}


#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification {
	NSLog(@"coordinateChanged");
	// Calculate swiss coordinates
    annotation = [self adaptPinSubtitle:annotation.coordinate];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	NSLog(@"didChangeDragState");
    
    // Get annotation and update the observation
	DDAnnotation *anno = (DDAnnotation *)annotationView.annotation;
    CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(anno.coordinate.latitude, anno.coordinate.longitude)
                                                             altitude:observation.location.altitude
                                                   horizontalAccuracy:observation.location.horizontalAccuracy
                                                     verticalAccuracy:observation.location.verticalAccuracy
                                                            timestamp:[NSDate date]];
    
    observation.location = newLocation;
    observation.locationLocked = true;
    
    observation.accuracy = 0;
    
    NSLog( @"set new location from annotation; accuracy: %d", observation.accuracy);
    pinMoved = true;
    
    
    if (oldState == MKAnnotationViewDragStateDragging) {
		annotation = (DDAnnotation *)annotationView.annotation;
        
        // Calculate swiss coordinates
        annotation = [self adaptPinSubtitle:annotation.coordinate];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annot {
	NSLog(@"viewForAnnotation");
    
    if ([annot isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
    MKPinAnnotationView *draggablePinView = [[MKPinAnnotationView alloc] initWithAnnotation:annot reuseIdentifier:kPinAnnotationIdentifier];
    draggablePinView.animatesDrop = YES;
    draggablePinView.draggable = YES;
	/*MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];*/
	
	/*if (draggablePinView) {
		draggablePinView.annotation = annot;
	} else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annot reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
	}*/		
	
	return draggablePinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKOverlayView *overlayView;
    
    NSLog(@"test %@", [overlay class]);
    
    if ([overlay class] == MKPolyline.class) {
        NSLog(@"overlay LINE");
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        lineView.fillColor = [UIColor colorWithRed:0 green:255/255.0 blue:0 alpha:pAlpha];
        lineView.strokeColor = [UIColor greenColor];
        lineView.lineWidth = pWidth;
        overlayView = lineView;
    } else if ([overlay class] == MKPolygon.class) {
        NSLog(@"overlay POLYGON");
        MKPolygonView *polyView = [[MKPolygonView alloc] initWithPolygon:overlay];
        polyView.fillColor = [UIColor colorWithRed:0 green:255/255.0 blue:0 alpha:pAlpha];
        polyView.strokeColor = [UIColor greenColor];
        polyView.lineWidth = pWidth;
        overlayView = polyView;
    }
    return overlayView;

}

@end
