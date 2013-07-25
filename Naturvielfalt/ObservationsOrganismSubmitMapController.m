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
#import "SBJson.h"

#define pWidth 5
#define pAlpha 0.1

@implementation ObservationsOrganismSubmitMapController
@synthesize mapView, currentLocation, observation, annotation, review, shouldAdjustZoom, pinMoved, locationManager, setButton, persistenceManager, searchBar, accuracyImage, accuracyText, accuracyImageView, accuracyLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        persistenceManager = [[PersistenceManager alloc] init];
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
    
    //observation = [[Observation alloc] getObservation];
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    
    // RELOCATE button
    /*UIBarButtonItem *relocate = [[UIBarButtonItem alloc] initWithTitle:@"GPS"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(relocate)];
    
    self.navigationItem.leftBarButtonItem = relocate;*/
    
    if(review || observation.locationLocked) {

        observation.locationLocked = YES;
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
    }
    
    
    // Set delegation and show users current position
    mapView.delegate = self;
    searchBar.delegate = self;

    // Register event for handling zooming in on users current position
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
    
    //searchBar placeholder
    searchBar.placeholder = NSLocalizedString(@"searchBarPlaceholder", nil);
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"observationLocalization", nil);
    self.navigationItem.title = title;
    
    CLLocationCoordinate2D theCoordinate;
    
    if (observation.location) {
        theCoordinate.longitude = observation.location.coordinate.longitude;
        theCoordinate.latitude = observation.location.coordinate.latitude;
    } else {
        mapView.showsUserLocation = YES;
        theCoordinate.longitude = mapView.userLocation.coordinate.longitude;
        theCoordinate.latitude = mapView.userLocation.coordinate.latitude;
    }

	
	annotation = [[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil];
	annotation.title = [NSString stringWithFormat:@"%@", [observation.organism getNameDe]];
    
    shouldAdjustZoom = YES;
    
    // Calculate swiss coordinates
    annotation = [self adaptPinSubtitle: theCoordinate];
    
    pinMoved = false;
    [setButton setTitle:NSLocalizedString(@"observationAdd", nil) forState:UIControlStateNormal];
    
	//[self.mapView addAnnotation:annotation];
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
    
    [self updateAccuracyIcon:currentAccuracy];
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (observation.observationId) {
        [persistenceManager establishConnection];
        observation = [persistenceManager getObservation:observation.observationId];
        Area *tmpArea = [persistenceManager getArea:observation.inventory.areaId];
        [persistenceManager closeConnection];
        
        observation.inventory.area = tmpArea;
        
        if (!observation) {
            [observation setObservation:nil];
            observation = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    if (!review || !observation.locationLocked) {
        CLLocationCoordinate2D theCoordinate;
        
        if (observation.location) {
            theCoordinate.longitude = observation.location.coordinate.longitude;
            theCoordinate.latitude = observation.location.coordinate.latitude;
        } else {
            if (observation.inventory) {
                LocationPoint *areaPoint = [observation.inventory.area.locationPoints objectAtIndex:0];
                theCoordinate.longitude = areaPoint.longitude;
                theCoordinate.latitude = areaPoint.latitude;
            } else {
                mapView.showsUserLocation = YES;
                theCoordinate.longitude = mapView.userLocation.coordinate.longitude;
                theCoordinate.latitude = mapView.userLocation.coordinate.latitude;
            }
        }
        
        annotation = [[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil];
        annotation.title = [NSString stringWithFormat:@"%@", [observation.organism getNameDe]];
        
        shouldAdjustZoom = YES;
        
        // Calculate swiss coordinates
        annotation = [self adaptPinSubtitle: theCoordinate];
        
        pinMoved = false;
        
        [self.mapView addAnnotation:annotation];
        review = YES;
    } else {
        shouldAdjustZoom = NO;
        [self zoomToAnnotation];
    }
    

    [self loadArea];
    
    /*if (!observation.locationLocked && !observation.inventory) {
        [self relocate:nil];
    }*/
}

- (void) updateAccuracyIcon:(int)accuracyValue {
    UIImage *green = [UIImage imageNamed:@"status-green.png"];
    UIImage *orange = [UIImage imageNamed:@"status-orange.png"];
    UIImage *red = [UIImage imageNamed:@"status-red.png"];
    
    if(accuracyValue <= 30) {
        accuracyImage = green;
    } else if(accuracyValue < 90) {
        accuracyImage = orange;
    } else {
        accuracyImage = red;
    }
    accuracyText = [[NSString alloc] initWithFormat:@"%dm %@", accuracyValue, NSLocalizedString(@"observationAcc", nil)];
    accuracyLabel.text = accuracyText;
    accuracyImageView.image = accuracyImage;
}

- (void) loadArea {
    if (observation.inventory) {
        NSMutableArray *locationPoints = [[NSMutableArray alloc] initWithArray:observation.inventory.area.locationPoints];
        
        MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
        CLLocationCoordinate2D coordinate;
        
        for (int index = 0; index < locationPoints.count; index++) {
            coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
            coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        
        switch (observation.inventory.area.typeOfArea) {
            case POINT:
            {
                MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
                anno.coordinate = coordinate;
                //DDAnnotation *anno = [[DDAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil];
                [mapView addAnnotation:anno];
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

- (IBAction) setPin:(id) sender {
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
    
    [self updateAccuracyIcon:currentAccuracy];
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
    observation.locationLocked = YES;
    observation.accuracy = currentAccuracy;
    observation.location = currentLocation;
    
    [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
    
    // Change view back to submitController
    /*ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                      initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Set the current displayed organism
    organismSubmitController.organism = observation.organism;*/
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    //[self.navigationController pushViewController:organismSubmitController animated:TRUE];
}


// Listen to change in the userLocation
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
    NSLog(@"observeValueForKeyPath");
    if(shouldAdjustZoom) {
        NSLog(@"zoom to user location");
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
    [self setSearchBar:nil];
    accuracyImageView = nil;
    [self setAccuracyLabel:nil];
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
        [self updateAccuracyIcon: (int)observation.accuracy];
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
    observation.locationLocked = YES;
    
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
	
    if ([annot class] != MKPointAnnotation.class) {
        static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
        MKPinAnnotationView *draggablePinView = [[MKPinAnnotationView alloc] initWithAnnotation:annot reuseIdentifier:kPinAnnotationIdentifier];
        draggablePinView.animatesDrop = YES;
        draggablePinView.pinColor = MKPinAnnotationColorRed;
        draggablePinView.draggable = YES;
        /*MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];*/
        
        /*if (draggablePinView) {
         draggablePinView.annotation = annot;
         } else {
         // Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
         draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annot reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
         }*/		
        
        return draggablePinView;
    } else {
        static NSString * const kPinAnnotationIdentifier = @"PinAreaIdentifier";
        MKPinAnnotationView *areaPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annot reuseIdentifier:kPinAnnotationIdentifier];
        areaPinView.pinColor = MKPinAnnotationColorGreen;
        return areaPinView;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKOverlayView *overlayView;
    
    NSLog(@"test %@", [overlay class]);
    
    if ([overlay class] == MKPolyline.class) {
        NSLog(@"overlay LINE");
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        lineView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:pAlpha];
        lineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        lineView.lineWidth = pWidth;
        overlayView = lineView;
    } else if ([overlay class] == MKPolygon.class) {
        NSLog(@"overlay POLYGON");
        MKPolygonView *polyView = [[MKPolygonView alloc] initWithPolygon:overlay];
        polyView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:pAlpha];
        polyView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        polyView.lineWidth = pWidth;
        overlayView = polyView;
    }
    return overlayView;
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void) searchBarSearchButtonClicked:(UISearchBar *)sb {
    NSLog(@"search");
    [searchBar resignFirstResponder];
    
    CLLocationCoordinate2D sLocation;
    if (searchBar.text.length > 0) {
        sLocation = [self geoCodeUsingAddress:sb.text];
    }
    
    MKCoordinateRegion region;
    region.center = sLocation;
    
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.009; // Change these values to change the zoom
    span.longitudeDelta = 0.009;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    
    NSDictionary *googleResponse = [[NSString stringWithContentsOfURL: [NSURL URLWithString: req] encoding: NSUTF8StringEncoding error: NULL]JSONValue];
    
    NSDictionary    *resultsDict = [googleResponse valueForKey:  @"results"];
    // get the results dictionary
    NSDictionary   *geometryDict = [resultsDict valueForKey: @"geometry"];
    // geometry dictionary within the  results dictionary
    NSDictionary   *locationDict = [geometryDict valueForKey: @"location"];
    // location dictionary within the geometry dictionary
    
    NSArray *latArray = [locationDict valueForKey: @"lat"];
    NSString *latString = [latArray lastObject];
    // (one element) array entries provided by the json parser
    
    NSArray *lngArray = [locationDict valueForKey: @"lng"];
    NSString *lngString = [lngArray lastObject];
    // (one element) array entries provided by the json parser
    
    CLLocationCoordinate2D location;
    location.latitude = [latString doubleValue];// latitude;
    location.longitude = [lngString doubleValue]; //longitude;
    
    return location;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([searchBar isFirstResponder] && [touch view] != searchBar)
    {
        [searchBar resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
