//
//  AreasViewController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.04.13.
//  Copyright (c) 2013 Naturwerk. All rights reserved.
//

#import "AreasViewController.h"
#import "AreasSubmitController.h"

@interface AreasViewController ()

@end

@implementation AreasViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Sichern"
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    
    // RELOCATE button
    UIBarButtonItem *relocate = [[UIBarButtonItem alloc] initWithTitle:@"GPS"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(relocate)];
    
    self.navigationItem.leftBarButtonItem = relocate;
    
    if(review) {        
        
        /*MKCoordinateRegion mapRegion = mapView.region;
        mapRegion.center = observation.location.coordinate;
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005; 
        mapRegion.span = span;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        // Update coordinate
        [annotation setCoordinate:observation.location.coordinate];
        
        self.mapView.showsUserLocation = NO;  
         */
        
    } else {
        
        if ([CLLocationManager locationServicesEnabled]) {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 1000.0f;
            [locationManager startUpdatingLocation];
        }
        mapView.showsUserLocation = YES;        
    }
    
    // Set delegation and show users current position
    mapView.delegate = self;
    
    // Register event for handling zooming in on users current position
    [mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                                   context:NULL];
    
    
    // Set navigation bar title    
    NSString *title = @"Lokalisierung";
    self.navigationItem.title = title;
    
    shouldAdjustZoom = YES;
}

- (void)viewDidUnload
{
    mapView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) relocate 
{
    self.navigationItem.leftBarButtonItem.action = @selector(GPSrelocate);
    self.navigationItem.leftBarButtonItem.title = @"GPS setzen";
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    mapView.showsUserLocation = YES;
}

- (void) GPSrelocate{
    
    [locationManager stopUpdatingLocation];
    
    review = false;
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    mapView.showsUserLocation = YES;
    
}

- (void) saveArea {
    NSLog(@"saveArea");
    
    // Change view back to submitController
    AreasSubmitController *areasSubmitController = [[AreasSubmitController alloc] 
                                                                      initWithNibName:@"AreasSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:areasSubmitController animated:TRUE];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (shouldAdjustZoom) {
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005;
        region.span = span;
        
        [mapView setRegion:region animated:YES];
        
        shouldAdjustZoom = false;
    }
}

- (IBAction)setPoint:(id)sender {
    NSLog(@"setPoint");
    
    if (!latitudeArray) {
        //points = malloc(sizeof(CLLocationCoordinate2D) * 5);
        latitudeArray = [[NSMutableArray alloc] init];
        longitudeArray = [[NSMutableArray alloc] init];
    }

    MKCoordinateRegion mapRegion = mapView.region;
    NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
    NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
    [longitudeArray addObject:longi];
    [latitudeArray addObject:lati];

    //[points addObject:[NSData dataWithBytes:&mapRegion.center length:sizeof(mapRegion.center)]];
    NSLog(@"add Point: longitude - %g latitude - %g", mapRegion.center.longitude, mapRegion.center.latitude);
    NSLog(@"numOfPoints: %ld", (unsigned long)longitudeArray.count);
    
    if (longitudeArray.count > 2) {
        // draw a marker sign for the first point
        [mapView removeOverlay:polygon];
        
        points = malloc(sizeof(CLLocationCoordinate2D) * longitudeArray.count);
        
        for (int index = 0; index < longitudeArray.count; index++) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [(NSNumber*)latitudeArray[index] doubleValue];
            coordinate.longitude = [(NSNumber*)longitudeArray[index] doubleValue];
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        
        polygon = [MKPolygon polygonWithPoints:points count:longitudeArray.count];
        [mapView addOverlay:polygon];
    }
    

}

- (IBAction)redo:(id)sender {
}

#pragma mark
#pragma CLLocationManagerDelegate Methodes
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
}

#pragma mark
#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    NSLog(@"mapView viewForOverlay");

    if(!overlayView) {
        overlayView = nil;
    }
    
    if(overlay == polygon) {
        polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
        polygonView.fillColor = [UIColor colorWithRed:122/255.0 green:174/255.0 blue:255 alpha:0.5f];
        polygonView.strokeColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5f];
        polygonView.lineWidth = 1;
        
        overlayView = polygonView;
    }
    return overlayView;
}


@end
