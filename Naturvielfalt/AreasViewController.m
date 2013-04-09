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
    
    
    // Cancel button
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Abbrechen"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(cancelPressed)];
    
    self.navigationItem.leftBarButtonItem = cancel;

    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        [locationManager startUpdatingLocation];
    }
    mapView.showsUserLocation = YES;        

    
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
    [self setUndoButton:nil];
    [self setSetButton:nil];
    [self setModeButton:nil];
    [self setGpsButton:nil];
    [self setHairlinecross:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void) cancelPressed {
    currentDrawMode = nil;
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlay:overlayView.overlay];
    longitudeArray = nil;
    latitudeArray = nil;
    [self showStartModeAppearance];
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
    
    [mapView removeOverlay:overlayView.overlay];
    _undoButton.enabled = YES;
    
    switch (currentDrawMode) {
        case POINT:
            NSLog(@"draw a point");
            [self drawPoint];
            break;
            
        case LINE: NSLog(@"draw a line");
            [self drawLine];
            break;
            
        case LINE_FH: NSLog(@"draw a line free-hand");
            break;
            
        case POLYGON: NSLog(@"draw a polygon");
            [self drawPolygon];
            break;
            
        case POLYGON_FH: NSLog(@"draw a polygon free-hand");
            break;
    }
}

- (void) drawPoint {
    if (!latitudeArray) {
        latitudeArray = [[NSMutableArray alloc] init];
        longitudeArray = [[NSMutableArray alloc] init];
    }
    
    MKCoordinateRegion mapRegion = mapView.region;
    NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
    NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
    [longitudeArray addObject:longi];
    [latitudeArray addObject:lati];
    // Sets the pin in the middle of the hairline cross
    if (!annotation) {
        annotation = [[DDAnnotation alloc] init];
    }
    [annotation setCoordinate:mapRegion.center];
    [mapView addAnnotation:annotation];
}

- (void) drawLine {
    if (!latitudeArray) {
        latitudeArray = [[NSMutableArray alloc] init];
        longitudeArray = [[NSMutableArray alloc] init];
    }
    
    if (!undo) {
        MKCoordinateRegion mapRegion = mapView.region;
        NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
        NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
        [longitudeArray addObject:longi];
        [latitudeArray addObject:lati];
    }
    
    points = malloc(sizeof(CLLocationCoordinate2D) * longitudeArray.count);
    NSLog(@"num of elements: %lu", (unsigned long)longitudeArray.count);
    
    for (int index = 0; index < longitudeArray.count; index++) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [(NSNumber*)latitudeArray[index] doubleValue];
        coordinate.longitude = [(NSNumber*)longitudeArray[index] doubleValue];
        MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
        points[index] = newPoint;
    }
    
    line = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
    [mapView addOverlay:line];
    

    [self drawStartPoint];
    
    undo = NO;
}

- (void) drawPolygon {
    if (!latitudeArray) {
        latitudeArray = [[NSMutableArray alloc] init];
        longitudeArray = [[NSMutableArray alloc] init];
    }
    
    if (!undo) {
        MKCoordinateRegion mapRegion = mapView.region;
        NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
        NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
        [longitudeArray addObject:longi];
        [latitudeArray addObject:lati];
    }

    points = malloc(sizeof(CLLocationCoordinate2D) * longitudeArray.count);
        
    for (int index = 0; index < longitudeArray.count; index++) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [(NSNumber*)latitudeArray[index] doubleValue];
        coordinate.longitude = [(NSNumber*)longitudeArray[index] doubleValue];
        MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
        points[index] = newPoint;
    }
    
    if (longitudeArray.count < 3) {
        line = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
        [mapView addOverlay:line];
        undo = NO;
    } else {
        polygon = [MKPolygon polygonWithPoints:points count:longitudeArray.count];
        [mapView addOverlay:polygon];
    }
        
    undo = NO;
}

- (void) drawStartPoint {
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [(NSNumber*)longitudeArray[0] doubleValue];
    coordinate.latitude = [(NSNumber*)latitudeArray[0] doubleValue];
    circle = [MKCircle circleWithCenterCoordinate:coordinate radius:10.0];
    [mapView addOverlay:circle];
}

- (IBAction)undo:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    CLLocationCoordinate2D cll;
    
    switch (currentDrawMode) {
        case POINT:
            [mapView removeAnnotation:annotation];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];
            break;
            
        case LINE:

            [mapView removeOverlay:overlayView.overlay];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];
            // set hairline cross to the last location
            span.latitudeDelta = 0.005;
            span.longitudeDelta = 0.005;
            cll.latitude = [(NSNumber*)latitudeArray.lastObject doubleValue];
            cll.longitude = [(NSNumber*)longitudeArray.lastObject doubleValue];
            region.span = span;
            region.center = cll;
            [mapView setRegion:region animated:YES];
            undo = YES;
            [self drawLine];
            break;
            
        case LINE_FH:
            break;
        case POLYGON:
            [mapView removeOverlay:overlayView.overlay];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];
            // set hairline cross to the last location
            span.latitudeDelta = 0.005;
            span.longitudeDelta = 0.005;
            cll.latitude = [(NSNumber*)latitudeArray.lastObject doubleValue];
            cll.longitude = [(NSNumber*)longitudeArray.lastObject doubleValue];
            region.span = span;
            region.center = cll;
            [mapView setRegion:region animated:YES];
            undo = YES;
            [self drawPolygon];
            break;
        case POLYGON_FH:
            break;
    }
}

- (void) showEditModeAppearance {
    _hairlinecross.hidden = NO;
    _undoButton.hidden = NO;
    _setButton.hidden = NO;
    _modeButton.hidden = YES;
}

- (void) showStartModeAppearance {
    _hairlinecross.hidden = YES;
    _undoButton.hidden = YES;
    _setButton.hidden = YES;
    _modeButton.hidden = NO;
}

- (void) showFreeHandModeAppearance {
    _hairlinecross.hidden = YES;
    _undoButton.hidden = NO;
    _setButton.hidden = YES;
    _modeButton.hidden = YES;
}

- (IBAction)showModeOptions:(id)sender {
    
    if (!modeOptions) {
        modeOptions = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:@"Pin",@"Linie",@"Linie (free-hand)", @"Polygon", @"Polygon (free-hand)", nil];
        modeOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    [modeOptions showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)relocate:(id)sender {
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    mapView.showsUserLocation = YES;

}

- (void) GPSrelocate {
    
   /* [locationManager stopUpdatingLocation];
    
    review = false;
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"start relocate");
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    mapView.showsUserLocation = YES;*/
}

#pragma mark
#pragma UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            currentDrawMode = POINT;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Point");
            break;
        case 1:
            currentDrawMode = LINE;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Line");
            break;
        case 2:
            currentDrawMode = LINE_FH;
            [self showFreeHandModeAppearance];
            NSLog(@"current draw mode: Line fh");
            break;
        case 3:
            currentDrawMode = POLYGON;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Polygon");
            break;
        case 4:
            currentDrawMode = POLYGON_FH;
            [self showFreeHandModeAppearance];
            NSLog(@"current draw mode: Polygon fh");
            break;
        case 5:
            NSLog(@"cancel pressed");
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma CLLocationManagerDelegate Methods
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
        polygonView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        polygonView.strokeColor = [UIColor blueColor];
        polygonView.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
        polygonView.lineWidth = 3;
        overlayView = polygonView;
        
    } else if (overlay == line) {
        lineView = [[MKPolylineView alloc] initWithPolyline:line];
        lineView.strokeColor = [UIColor blueColor];
        lineView.lineWidth = 3;
        lineView.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
        overlayView = lineView;
    } else if (overlay == circle) {
        circleView = [[MKCircleView alloc] initWithCircle:circle];
        circleView.fillColor = [UIColor whiteColor];
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 3;
        overlayView = circleView;
    }
    return overlayView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    /*MKPinAnnotationView *pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    pav.pinColor = MKPinAnnotationColorGreen;
    return pav;*/
    return nil;
}


@end
