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

@implementation ObservationsOrganismSubmitMapController
@synthesize mapView, currentLocation, observation, annotation, review, shouldAdjustZoom, pinMoved;

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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Zurück"
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(returnBack)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    observation = [[[Observation alloc] init] getObservation];
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    if(review) {
        // RELOCATE button not implemented yet
        /*UIBarButtonItem *relocate = [[UIBarButtonItem alloc] initWithTitle:@"Relocate"
                                                                       style:UIBarButtonItemStylePlain 
                                                                      target:self 
                                                                      action:@selector(relocate)];
        
        self.navigationItem.rightBarButtonItem = relocate;
        [relocate release];
        */

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

    // Register event for handling zooming in on users current position
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
    
    
    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithString:@"Lokalisierung"];
    self.navigationItem.title = title;
    
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.longitude = observation.location.coordinate.longitude;
    theCoordinate.latitude = observation.location.coordinate.latitude;
	
	annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
	annotation.title = [NSString stringWithFormat:@"%@", [observation.organism getNameDe]];
    
    shouldAdjustZoom = YES;
    
    // Calculate swiss coordinates
    annotation = [self adaptPinSubtitle:annotation withCoordinate:theCoordinate];
    
    pinMoved = false;
    
    self.mapView.mapType = MKMapTypeHybrid;
	[self.mapView addAnnotation:annotation];	
}

- (DDAnnotation *) adaptPinSubtitle:(DDAnnotation *)annotation withCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    // Calculate swiss coordinates
    SwissCoordinates *swissCoordinates = [[SwissCoordinates alloc] init];
    NSMutableArray *arrayCoordinates = [swissCoordinates calculate:theCoordinate.longitude latitude:theCoordinate.latitude];
    annotation.subtitle = [NSString	stringWithFormat:@"CH03 (%.0f, %.0f) \n WGS84 (%.3f, %.3f)", [[arrayCoordinates objectAtIndex:0] doubleValue], [[arrayCoordinates objectAtIndex:1] doubleValue], theCoordinate.longitude, theCoordinate.latitude];
    
    return annotation;
}

- (void) relocate 
{
   
}

- (void) returnBack 
{
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
    [organismSubmitController release];
    organismSubmitController = nil;
}

- (void) viewDidAppear:(BOOL)animated 
{
    
}

// Listen to change in the userLocation
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
    if(shouldAdjustZoom) {   
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;  
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005; 
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
        
        shouldAdjustZoom = false;
        
        [annotation setCoordinate:self.mapView.userLocation.coordinate];
    }

    if(!pinMoved)
        [annotation setCoordinate:self.mapView.userLocation.coordinate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void) dealloc 
{
    [super dealloc];    
    
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    // [self.mapView removeFromSuperview];
    // self.mapView = nil;
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
     if(!observation.locationLocked && !review) {
        // update observation value
        observation.location = newLocation;
        
        MKCoordinateRegion mapRegion = mapView.region;
        mapRegion.center = newLocation.coordinate;
        self.mapView.region = mapRegion;     
    }
    
    [annotation setCoordinate:newLocation.coordinate];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Kein Netzwerk vorhanden. Ev. im Flugmodus?" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"GPS wurde vom Benutzer für diese Applikation deaktiviert. " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unbekannter Netzwerk Error." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
    }
}


#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification {
	
	DDAnnotation *annotation = notification.object;
    
    // Calculate swiss coordinates
    annotation = [self adaptPinSubtitle:annotation withCoordinate:annotation.coordinate];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
    // Get annotation and update the observation
	DDAnnotation *anno = (DDAnnotation *)annotationView.annotation;
    CLLocation *newLocation = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(anno.coordinate.latitude, anno.coordinate.longitude)
                                                             altitude:observation.location.altitude
                                                   horizontalAccuracy:observation.location.horizontalAccuracy
                                                     verticalAccuracy:observation.location.verticalAccuracy
                                                            timestamp:[NSDate date]] autorelease];
    
    observation.location = newLocation;
    observation.locationLocked = true;
    
    observation.accuracy = 0;
    
    pinMoved = true;
    
    
    if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
        
        // Calculate swiss coordinates
        annotation = [self adaptPinSubtitle:annotation withCoordinate:annotation.coordinate];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
        
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}		
	
	return draggablePinView;
}

@end
