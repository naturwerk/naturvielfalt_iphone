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
    _cancel = [[UIBarButtonItem alloc] initWithTitle:@"Abbrechen"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(cancelPressed)];
    _cancel.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = _cancel;

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

- (void) prepareData {
    
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
    NSLog(@"cancel current drawing!");
    
    if (longitudeArray.count > 0) {
       // remove polygon or line
        if (currentDrawMode != POINT) {
            // Remove startPoint from map
            [mapView removeAnnotation:annotationView.annotation];
            [mapView removeOverlay:overlayView.overlay];
        } else {
            // Remove pin from map
            [mapView removeAnnotation:pinAnnotationView.annotation];
        }
        
        [longitudeArray removeAllObjects];
        [latitudeArray removeAllObjects];
    }
    
    //[mapView setScrollEnabled:YES];
    _cancel.enabled = NO;
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

// Action Method, when the "setzen" button was pressed
- (IBAction)setPoint:(id)sender {
    NSLog(@"setPoint");
    
    // remove polygon or line
    if (currentDrawMode != POINT) {
        [mapView removeOverlay:overlayView.overlay];
    }
    
    _undoButton.enabled = YES;
    _cancel.enabled = YES;
    
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

// draw a single point (PIN)
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
    if (!pinAnnotation) {
        pinAnnotation = [[DDAnnotation alloc] init];
        pinAnnotation.title = @"Test title";
    }

    [mapView removeAnnotation:pinAnnotation];
    [pinAnnotation setCoordinate:mapRegion.center];
    [mapView addAnnotation:pinAnnotation];
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
    
    [self drawStartPoint];
    
    undo = NO;
}

// Set an annotation for the start point
- (void) drawStartPoint {
    NSLog(@"draw start point");
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [(NSNumber*)longitudeArray[0] doubleValue];
    coordinate.latitude = [(NSNumber*)latitudeArray[0] doubleValue];
    if (!startPoint) {
        startPoint = [[DDAnnotation alloc] init];
    }
    [startPoint setCoordinate:coordinate];
    [mapView addAnnotation:startPoint];
}

- (IBAction)undo:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    CLLocationCoordinate2D cll;
    
    switch (currentDrawMode) {
        case POINT:
            [mapView removeAnnotation:pinAnnotation];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];
            break;
            
        case LINE:
            [mapView removeOverlay:line];
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
            [mapView removeOverlay:polygon];
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
        modeOptions = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:@"Pin",@"Linie",/*@"Linie (free-hand)",*/ @"Polygon", /*@"Polygon (free-hand)",*/ nil];
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
#pragma Event handling for free-hand mode

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touch began");
    NSSet *allTouches = [event allTouches];
    
    for (UITouch *touch in allTouches) {
        CGPoint location = [touch locationInView:touch.view];
            NSLog(@"touch point: longi - %f lati - %f", location.x, location.y);
    }



    currentPath = [UIBezierPath bezierPath];
    currentPath.lineWidth = 3;

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch moved");
    UITouch *touch = [touches anyObject];
    [currentPath addLineToPoint:[touch locationInView:mapView]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended");
}*/

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
        /*case 2:
            currentDrawMode = LINE_FH;
            [mapView setScrollEnabled:NO];
            [self showFreeHandModeAppearance];
            NSLog(@"current draw mode: Line fh");
            break;*/
        case 2:
            currentDrawMode = POLYGON;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Polygon");
            break;
        /*case 3:
            currentDrawMode = POLYGON_FH;
            [self showFreeHandModeAppearance];
            NSLog(@"current draw mode: Polygon fh");
            break;*/
        case 3:
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


    if(!overlayView) {
        overlayView = nil;
    }
    
    if(overlay == polygon) {
        NSLog(@"mapView viewForOverlay - Polygon");
        polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
        polygonView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        polygonView.strokeColor = [UIColor blueColor];
        polygonView.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
        polygonView.lineWidth = 3;
        overlayView = polygonView;
        
    } else if (overlay == line) {
        NSLog(@"mapView viewForOverlay - Line");
        lineView = [[MKPolylineView alloc] initWithPolyline:line];
        lineView.strokeColor = [UIColor blueColor];
        lineView.lineWidth = 3;
        lineView.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
        overlayView = lineView;
        
    }
    return overlayView;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"mapView viewForAnnotation");
    annotationViewID = @"annotationViewID";
    pinAnnotationViewID = @"pinAnnotationViewID";
    
    switch (currentDrawMode) {
        
        case POINT:
            NSLog(@"annotation for POINT Mode");
            pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotationViewID];
            
            if (pinAnnotationView == nil)
            {
                NSLog(@"set pin settings (Color, animates, etc.)");
                pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotationViewID];
                pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
                pinAnnotationView.animatesDrop = YES;
                pinAnnotationView.canShowCallout = YES;
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                pinAnnotationView.rightCalloutAccessoryView = rightButton;
            }
            pinAnnotationView.annotation = annotation;
            
            return pinAnnotationView;
            break;
            
        case LINE:
            NSLog(@"annotation for LINE Mode");
            annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewID];
            
            if (annotationView == nil)
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewID];
            }
            
            annotationView.image = [UIImage imageNamed:@"startPoint.png"];
            break;
        
        case POLYGON:
            NSLog(@"annotation for POLYGON Mode");
            annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewID];
            
            if (annotationView == nil)
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewID];
            }
            
            annotationView.image = [UIImage imageNamed:@"startPoint.png"];
            break;
            
        default:
            break;
    }
    

    
    // Doesn't work vor MKPinAnnotationView, only vor MKAnnotationView!
    //annotationView.image = [UIImage imageNamed:@"symbol-line.png"];
    annotationView.annotation = annotation;
    
    return annotationView;
}



@end
