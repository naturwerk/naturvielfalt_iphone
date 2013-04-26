//
//  AreasViewController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.04.13.
//  Copyright (c) 2013 Naturwerk. All rights reserved.
//

#import "AreasViewController.h"
#import "AreasSubmitController.h"
#import "MKPolyline+MKPolylineCategory.h"
#import "MKPolygon+MKPolygonCategory.h"

@interface AreasViewController ()

@end

@implementation AreasViewController
@synthesize area;

//This method will called from annotations view,
//if the user clicks on the edit button of a given annotation.
- (void) setAnnotationInEditMode:(CustomAnnotation*)annotation {
    NSLog(@"setAnnotationInEditMode");
    
    [mapView removeAnnotation:annotation];

    annotation.persisted = NO;
    area = annotation.area;
    area.persisted = NO;
    
    longitudeArray = [[NSMutableArray alloc] initWithArray:annotation.area.longitudeArray];
    latitudeArray = [[NSMutableArray alloc] initWithArray:annotation.area.latitudeArray];
    currentDrawMode = annotation.annotationType;
    startPoint = annotation;
    
    // set hairline cross to the last location
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D cll;
    cll.latitude = [(NSNumber*)latitudeArray.lastObject doubleValue];
    cll.longitude = [(NSNumber*)longitudeArray.lastObject doubleValue];
    MKCoordinateRegion region;
    region.span = span;
    region.center = cll;
    [mapView setRegion:region animated:YES];
    
    switch (currentDrawMode) {
        case POINT:
        {
            [self drawPoint];
            break;
        }
        case LINE:
        {
            [mapView removeOverlay:annotation.overlay];
            [self drawLine];
            break;
        }
        case POLYGON:
        {
            [mapView removeOverlay:annotation.overlay];
            [self drawPolygon];
            break;
        }
    }
    [self showEditModeAppearance];
    [self checkForUndo];
    [self checkForSaving];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil area:(Area *)a
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        area = a;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Sichern"
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(saveArea)];
    
    _saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _saveButton;
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    
    // Cancel button
    _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Abbrechen"
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(cancelPressed)];
    _cancelButton.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = _cancelButton;

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


- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    
    if (area.persisted) {
        [self showPersistedAppearance];
        [self showStartModeAppearance];
    }

    for (id<MKAnnotation> annotation in mapView.selectedAnnotations) {
        [mapView deselectAnnotation:annotation animated:NO];
    }
}

- (void)viewDidUnload
{
    mapView = nil;
    [self setUndoButton:nil];
    [self setSetButton:nil];
    [self setModeButton:nil];
    [self setGpsButton:nil];
    [self setHairlinecross:nil];
    locationManager = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadOutAnnotations
{
    
}

- (void) showPersistedAppearance {
    NSLog(@"show persisted area appereance");

    switch (currentDrawMode) {
        case POINT:
        {
            pinAnnotation.persisted = YES;
            [mapView removeAnnotation:pinAnnotation];
            startPoint = pinAnnotation;
            [self drawStartPoint];
            break;
        }
        case LINE:
        {
            customLine.persisted = YES;
            [mapView removeOverlay:overlayView.overlay];
            startPoint.persisted = YES;
            [self drawLine];
            startPoint.overlay = customLine;
            break;
        }
        case POLYGON:
        {
            customPolygon.persisted = YES;
            [mapView removeOverlay:overlayView.overlay];
            startPoint.persisted = YES;
            [self drawPolygon];
            startPoint.overlay = customPolygon;
            break;
        }
    }
    
    [longitudeArray removeAllObjects];
    [latitudeArray removeAllObjects];
    currentDrawMode = 0;
    customLine = nil;
    customPolygon = nil;
    startPoint = nil;
    pinAnnotation = nil;
    overlayView = nil;
    area = nil;
}

- (void) saveArea {
    NSLog(@"saveArea");
    
    // Change view back to submitController
    AreasSubmitController *areasSubmitController = [[AreasSubmitController alloc] 
                                                                      initWithNibName:@"AreasSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    if (!area) {
        area = [[Area alloc] init];
    }

    area.typeOfArea = currentDrawMode;
    area.longitudeArray = [[NSMutableArray alloc] initWithArray:longitudeArray];
    area.latitudeArray = [[NSMutableArray alloc] initWithArray:latitudeArray];
    areasSubmitController.area = area;
    
    if (!overlaysArray) {
        overlaysArray = [[NSMutableArray alloc] init];
        annotationsArray = [[NSMutableArray alloc] init];
    }
    
    switch (currentDrawMode) {
        case POINT:
        {
            [annotationsArray addObject:pinAnnotation];
            break;
        }  
        case LINE:
        {
            customLine.area = area;
            [overlaysArray addObject:customLine];
            break;
        }
        case POLYGON:
        {
            customPolygon.area = area;
            [overlaysArray addObject:customPolygon];
            break;
        }
    }
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
            [mapView removeAnnotation:customAnnotationView.annotation];
            [mapView removeOverlay:overlayView.overlay];
        } else {
            // Remove pin from map
            [mapView removeAnnotation:pinAnnotation];
        }
        
        [longitudeArray removeAllObjects];
        [latitudeArray removeAllObjects];
    }
    _cancelButton.enabled = NO;
    startPoint = nil;
    [self showStartModeAppearance];
}

// Action Method, when the "setzen" button was pressed
- (IBAction)setPoint:(id)sender {
    NSLog(@"setPoint");
    _undoButton.enabled = YES;
    
    // remove polygon or line
    if (currentDrawMode != POINT) {
        [mapView removeOverlay:overlayView.overlay];
    } else {
        if (pinAnnotation) {
            [mapView removeAnnotation:pinAnnotation];
        }
    }
    
    if (!latitudeArray) {
        latitudeArray = [[NSMutableArray alloc] init];
        longitudeArray = [[NSMutableArray alloc] init];
    }
    
    MKCoordinateRegion mapRegion = mapView.region;
    NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
    NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
    [longitudeArray addObject:longi];
    [latitudeArray addObject:lati];
    
    switch (currentDrawMode) {
        case POINT:
        {
            NSLog(@"draw a point");
            [longitudeArray removeAllObjects];
            [latitudeArray removeAllObjects];
            MKCoordinateRegion mapRegion = mapView.region;
            NSNumber *longi = [NSNumber numberWithDouble:mapRegion.center.longitude];
            NSNumber *lati = [NSNumber numberWithDouble:mapRegion.center.latitude];
            [longitudeArray addObject:longi];
            [latitudeArray addObject:lati];
            _saveButton.enabled = YES;
            [self drawPoint];
            break;
        }
            
        case LINE:
        {
            NSLog(@"draw a line");

            [self drawLine];
            [self checkForSaving];
            break;
        }
            
        case POLYGON:
        {
            NSLog(@"draw a polygon");
            [self drawPolygon];
            [self checkForSaving];
            break;
        }
    }
}

// draw a single point (PIN)
- (void) drawPoint {
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [(NSNumber*)longitudeArray[0] doubleValue];
    coordinate.latitude = [(NSNumber*)latitudeArray[0] doubleValue];
    
    // Sets the pin in the middle of the hairline cross
    if (pinAnnotation) {
        if (pinAnnotation.persisted) {
            pinAnnotation = [[CustomAnnotation alloc]initWithWithCoordinate:coordinate type:currentDrawMode area:area];
            pinAnnotation.persisted = YES;
        }else {
            pinAnnotation = [[CustomAnnotation alloc]initWithWithCoordinate:coordinate type:currentDrawMode area:area];
            pinAnnotation.persisted = NO;
        }
    } else {
        pinAnnotation = [[CustomAnnotation alloc]initWithWithCoordinate:coordinate type:currentDrawMode area:area];
        pinAnnotation.persisted = NO;
    }
    
    [mapView addAnnotation:pinAnnotation];
}

// draw a line, it must have two points at least for saving
- (void) drawLine {
    
    if (longitudeArray.count > 1) {
        points = malloc(sizeof(CLLocationCoordinate2D) * longitudeArray.count);
        
        for (int index = 0; index < longitudeArray.count; index++) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [(NSNumber*)latitudeArray[index] doubleValue];
            coordinate.longitude = [(NSNumber*)longitudeArray[index] doubleValue];
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        if (customLine) {
            if (!customLine.persisted) {
                customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
                [customLine setPersisted:NO];
            } else {
                customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
                [customLine setPersisted:YES];
            }
        } else {
            customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
            [customLine setPersisted:NO];
        }
        [customLine setType:currentDrawMode];
        [mapView addOverlay:customLine];
    }
    
    [self drawStartPoint];
    
    undo = NO;
}

// draw a polygon, it must have three points at least
- (void) drawPolygon {
    points = malloc(sizeof(CLLocationCoordinate2D) * longitudeArray.count);
        
    for (int index = 0; index < longitudeArray.count; index++) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [(NSNumber*)latitudeArray[index] doubleValue];
        coordinate.longitude = [(NSNumber*)longitudeArray[index] doubleValue];
        MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
        points[index] = newPoint;
    }
    
    if (longitudeArray.count < 3) {
        if (customLine) {
            if (!customLine.persisted) {
                customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
                [customLine setPersisted:NO];
                
            } else {
                customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
                [customLine setPersisted:YES];
            }
            [customLine setType:currentDrawMode];
            [mapView addOverlay:customLine];
        } else {
            customLine = [MKPolyline polylineWithPoints:points count:longitudeArray.count];
            [customLine setPersisted:NO];
            [customLine setType:currentDrawMode];
            [mapView addOverlay:customLine];
        }

        undo = NO;
    } else {
        if (customPolygon) {
            if (!customPolygon.persisted) {
                customPolygon = [MKPolygon polygonWithPoints:points count:longitudeArray.count];
                [customPolygon setPersisted:NO];
                
            } else {
                customPolygon = [MKPolygon polygonWithPoints:points count:longitudeArray.count];
                [customPolygon setPersisted:YES];
            }
            [customPolygon setType:currentDrawMode];
            [mapView addOverlay:customPolygon];
        } else {
            customPolygon = [MKPolygon polygonWithPoints:points count:longitudeArray.count];
            [customPolygon setPersisted:NO];
            [customPolygon setType:currentDrawMode];
            [mapView addOverlay:customPolygon];
        }
    }
    
    [self drawStartPoint];
    
    undo = NO;
}

// Set an annotation for the start point (small rectangle)
- (void) drawStartPoint {
    NSLog(@"draw start point");
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [(NSNumber*)longitudeArray[0] doubleValue];
    coordinate.latitude = [(NSNumber*)latitudeArray[0] doubleValue];
    if (startPoint) {
        [mapView removeAnnotation:startPoint];
        if (startPoint.persisted) {
            startPoint = [[CustomAnnotation alloc] initWithWithCoordinate:coordinate type:currentDrawMode area:area];
            startPoint.persisted = YES;
        } else {
            if (!startPoint.area) {
                startPoint = [[CustomAnnotation alloc] initWithWithCoordinate:coordinate type:currentDrawMode area:area];
            } else {
                startPoint = [[CustomAnnotation alloc] initWithWithCoordinate:coordinate type:currentDrawMode area:startPoint.area];
            }
            startPoint.persisted = NO;
        }
        startPoint.annotationType = currentDrawMode;
    } else {
        startPoint = [[CustomAnnotation alloc] initWithWithCoordinate:coordinate type:currentDrawMode area:area];
        startPoint.annotationType = currentDrawMode;
        startPoint.persisted = NO;
    }
    [mapView addAnnotation:startPoint];
}

- (IBAction)undo:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    CLLocationCoordinate2D cll;
    BOOL isOnlyOnePoint = NO;
    
    switch (currentDrawMode) {
        case POINT:
        {
            [mapView removeAnnotation:customAnnotationView.annotation];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];
            _saveButton.enabled = NO;
            break;
        }
        case LINE:
        {
            [mapView removeOverlay:overlayView.overlay];
            isOnlyOnePoint = [self deleteStartPoint];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];

            if (!isOnlyOnePoint) {
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
            }
            break;
        }
        case POLYGON:
        {
            [mapView removeOverlay:overlayView.overlay];
            isOnlyOnePoint = [self deleteStartPoint];
            [longitudeArray removeLastObject];
            [latitudeArray removeLastObject];

            if (!isOnlyOnePoint) {
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
            }
            break;
        }
    }
    
    [self checkForUndo];
    [self checkForSaving];
}

// checks if the undo button should be enabled or not
- (void) checkForUndo {
    
    if (longitudeArray.count > 0) {
        _undoButton.enabled = YES;
        return;
    }
    _undoButton.enabled = NO;
}

- (void) checkForSaving {
    
    switch (currentDrawMode) {
        case LINE:
        {
            if (longitudeArray.count > 1) {
                _saveButton.enabled = YES;
                return;
            }
            _saveButton.enabled = NO;
            break;
        }
        case POLYGON:
        {
            if (longitudeArray.count > 2) {
                _saveButton.enabled = YES;
                return;
            }
            _saveButton.enabled = NO;
            break;
        }
    }
}

- (BOOL) deleteStartPoint {
    if (longitudeArray.count == 1) {
        NSLog(@"delete start point");
        [mapView removeAnnotation:customAnnotationView.annotation];
        _saveButton.enabled = NO;
        return YES;
    }
    return NO;
}

- (void) showEditModeAppearance {
    _hairlinecross.hidden = NO;
    _undoButton.hidden = NO;
    _setButton.hidden = NO;
    _modeButton.hidden = YES;
    _undoButton.enabled = NO;
}

- (void) showStartModeAppearance {
    _saveButton.enabled = NO;
    _hairlinecross.hidden = YES;
    _undoButton.hidden = YES;
    _setButton.hidden = YES;
    _modeButton.hidden = NO;
    _cancelButton.enabled = NO;
}

- (void) showFreeHandModeAppearance {
    _hairlinecross.hidden = YES;
    _undoButton.hidden = NO;
    _setButton.hidden = YES;
    _modeButton.hidden = YES;
}

- (IBAction)showModeOptions:(id)sender {
    
    if (!modeOptions) {
        modeOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:@"Pin",@"Linie",/*@"Linie (free-hand)",*/ @"Polygon", /*@"Polygon (free-hand)",*/ nil];
        
        UIImageView *pinSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(50, 31, 25, 25)];
        [pinSymbol setImage:[UIImage imageNamed:@"symbol-pin.png"]];
        [modeOptions addSubview:pinSymbol];
        
        UIImageView *lineSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(50, 84, 25, 25)];
        [lineSymbol setImage:[UIImage imageNamed:@"symbol-line.png"]];
        [modeOptions addSubview:lineSymbol];
        
        UIImageView *polygonSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(50, 137, 25, 25)];
        [polygonSymbol setImage:[UIImage imageNamed:@"symbol-polygon.png"]];
        [modeOptions addSubview:polygonSymbol];

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
    
    shouldAdjustZoom = YES;
    mapView.showsUserLocation = YES;
}


#pragma mark
#pragma UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            currentDrawMode = POINT;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Point");
            break;
        }
        case 1:
        {
            currentDrawMode = LINE;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Line");
            break;
        }
        case 2:
        {
            currentDrawMode = POLYGON;
            [self showEditModeAppearance];
            NSLog(@"current draw mode: Polygon");
            break;
        }
        case 3:
        {
            NSLog(@"cancel pressed");
            break;
        }
    }
    _cancelButton.enabled = YES;
}

#pragma mark
#pragma CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
}

// Listen to change in the userLocation
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(shouldAdjustZoom) {
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.005; // Change these values to change the zoom
        span.longitudeDelta = 0.005;
        region.span = span;
        
        [mapView setRegion:region animated:YES];
        mapView.showsUserLocation = YES;
        shouldAdjustZoom = false;
    }
}

#pragma mark
#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {

    NSLog(@"mapView viewForOverlay");
    NSLog(@"class of overlay: %@", [overlay class]);
    
    overlayView = nil;
    
    if (overlay == customLine) {
        NSLog(@"overlay LINE");
        customLineView = [[CustomLineView alloc] initWithPolyline:customLine];
        overlayView = customLineView;
        
    } else if (overlay == customPolygon) {
        NSLog(@"overlay POLYGON");
        customPolygonView = [[CustomPolygonView alloc] initWithPolygon:customPolygon];
        overlayView = customPolygonView;
    }
    return overlayView;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"mapView viewForAnnotation");

    // return nil, if annotation is user location
    if ([annotation class] == MKUserLocation.class) {
        return nil;
    }
    
    customAnnotationView = nil;
    customAnnotation = (CustomAnnotation*) annotation;
    
    switch (customAnnotation.annotationType) {
        case POINT:
        {
            NSLog(@"annotation for POINT Mode");
            NSString *identifier = @"PinAnnotationId";
            
            CustomAnnotationView *newAnnotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

            newAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:customAnnotation reuseIdentifier:identifier navigationController:self.navigationController areasViewController:self];

                
            customAnnotationView = newAnnotationView;
            break;
        }
        case LINE:
        {
            NSLog(@"annotation for LINE Mode");
            NSString *identifier = @"LineAnnotationId";
            CustomAnnotationView *newAnnotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            newAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:customAnnotation reuseIdentifier:identifier navigationController:self.navigationController areasViewController:self];
            
            customAnnotationView = newAnnotationView;
            break;
        }
        case POLYGON:
        {
            NSLog(@"annotation for POLYGON Mode");
            NSString *identifier = @"PolygonAnnotationId";
            CustomAnnotationView *newAnnotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            newAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:customAnnotation reuseIdentifier:identifier navigationController:self.navigationController areasViewController:self];

            customAnnotationView = newAnnotationView;
            break;
        }
    }
    [customAnnotationView setEnabled:YES];
    
    return customAnnotationView;
}



@end
