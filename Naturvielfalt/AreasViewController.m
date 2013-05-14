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
#import "LocationPoint.h"

#define imgX      70
#define pinY      31
#define lineY     84
#define polyY    137
#define imgWidht  25
#define imgHeight 25

@implementation AreasViewController
@synthesize area, cancelButton, saveButton, undoButton, setButton, gpsButton, modeButton, hairlinecross;

//This method will called from annotations view,
//if the user clicks on the edit button of a given annotation.
- (void) setAnnotationInEditMode:(CustomAnnotation*)annotation {
    NSLog(@"setAnnotationInEditMode");
    
    [mapView removeAnnotation:annotation];

    annotation.persisted = NO;
    area = annotation.area;
    area.persisted = NO;
    
    locationPoints = [[NSMutableArray alloc] initWithArray:annotation.area.locationPoints];
    currentDrawMode = annotation.annotationType;
    startPoint = annotation;
    
    // set hairline cross to the last location
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D cll;
    cll.latitude = ((LocationPoint*)locationPoints.lastObject).latitude;
    cll.longitude = ((LocationPoint*)locationPoints.lastObject).longitude;
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
    
    saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(saveArea)];
    
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Start locationManager
    locationManager = [[CLLocationManager alloc] init];
    
    
    // Cancel button
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navCancel", nil)
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(cancelPressed)];
    cancelButton.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = cancelButton;

    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        [locationManager startUpdatingLocation];
    }
    mapView.showsUserLocation = YES;        

    
    // Set delegation and show users current position
    mapView.delegate = self;
    
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"areaNavTitle", nil);
    self.navigationItem.title = title;
    
    [undoButton setTitle:NSLocalizedString(@"areaUndo", nil) forState:UIControlStateNormal];
    [setButton setTitle:NSLocalizedString(@"areaAdd", nil) forState:UIControlStateNormal];
    
    shouldAdjustZoom = YES;
    
    [self loadAreas];
    if (mapView.overlays.count > 0 || mapView.annotations.count > 0) {
        [self showAllAreasInRect];
    } else {
        [self relocate:nil];
    }
}


- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    
    if (area.persisted) {
        [self showPersistedAppearance];
        [self showStartModeAppearance];
    }
    [self showStartModeAppearance];
    locationPoints = nil;
    currentDrawMode = 0;
    area = nil;

    for (id<MKAnnotation> annotation in mapView.selectedAnnotations) {
        [mapView deselectAnnotation:annotation animated:NO];
    }
    [self loadAreas];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite;break;}
        case 2:{mapView.mapType = MKMapTypeHybrid;break;}
        case 3:{mapView.mapType = MKMapTypeStandard;break;}
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

- (void) deleteAllAreasOnMap {
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
}

- (void) loadAreas
{
    [self deleteAllAreasOnMap];
    
    if (!persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    [persistenceManager establishConnection];
    
    NSMutableArray *areas = [persistenceManager getAreas];
    // Close connection
    [persistenceManager closeConnection];

    for (Area *a in areas) {
        area = a;
        locationPoints = [[NSMutableArray alloc] initWithArray:area.locationPoints];
        area.persisted = YES;
        currentDrawMode = area.typeOfArea;
        
        points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
        
        for (int index = 0; index < locationPoints.count; index++) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
            coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        
        switch (area.typeOfArea) {
            case POINT:
            {
                CLLocationCoordinate2D coordinate;
                coordinate.longitude = ((LocationPoint*)locationPoints[0]).longitude;
                coordinate.latitude = ((LocationPoint*)locationPoints[0]).latitude;
                pinAnnotation = [[CustomAnnotation alloc]initWithWithCoordinate:coordinate type:currentDrawMode area:area];
                pinAnnotation.persisted = YES;
                pinAnnotation.area = area;
                [self drawPoint];
                break;
            }
            case LINE:
            {
                customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                customLine.persisted = YES;
                customLine.area = area;
                [self drawLine];
                startPoint.overlay = customLine;
                break;
            }
            case POLYGON:
            {
                if (locationPoints.count > 2) {
                    customPolygon = [MKPolygon polygonWithPoints:points count:locationPoints.count];
                    customPolygon.persisted = YES;
                    customPolygon.area = area;
                    [self drawPolygon];
                    startPoint.overlay = customPolygon;
                } else {
                    customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                    customLine.persisted = YES;
                    customLine.area = area;
                    [self drawPolygon];
                    startPoint.overlay = customLine;
                }
            }
        }
        [self showPersistedAppearance];
    }
}

- (void) showAllAreasInRect {
    
    NSLog(@"showAllAreasInRect");
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in mapView.overlays) {
        if (MKMapRectIsNull(flyTo)) {
            flyTo = [overlay boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
    }
    
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 25, 25);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    flyTo.origin.x -= 25000;
    //flyTo.origin.y += 25000;
    flyTo.size.width += 50000;
    //flyTo.size.height +=50000;
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = flyTo;
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
    [locationPoints removeAllObjects];
    currentDrawMode = 0;
    customLine = nil;
    customPolygon = nil;
    startPoint = nil;
    pinAnnotation = nil;
    overlayView = nil;
    [area setArea:nil];
    area = nil;
}

- (void) saveArea {
    NSLog(@"save Area");
    
    // Change view back to submitController
    AreasSubmitController *areasSubmitController = [[AreasSubmitController alloc] 
                                                                      initWithNibName:@"AreasSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    if (!area) {
        area = [[Area alloc] getArea];
    }

    area.typeOfArea = currentDrawMode;
    area.locationPoints = [[NSMutableArray alloc] initWithArray:locationPoints];
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
    //[self.navigationController popViewControllerAnimated:TRUE];
    
    if (area.areaId) {
        areasSubmitController.review = YES;
    }
    
    // PUSH
    [self.navigationController pushViewController:areasSubmitController animated:TRUE];
}

- (void) cancelPressed {
    NSLog(@"cancel current drawing!");
    
    if (locationPoints.count > 0) {
       // remove polygon or line
        if (currentDrawMode != POINT) {
            // Remove startPoint from map
            [mapView removeAnnotation:customAnnotationView.annotation];
            [mapView removeOverlay:overlayView.overlay];
        } else {
            // Remove pin from map
            [mapView removeAnnotation:pinAnnotation];
        }
        [locationPoints removeAllObjects];
    }
    cancelButton.enabled = NO;
    startPoint = nil;
    [self showStartModeAppearance];
}

// Action Method, when "add" button was pressed
- (IBAction)setPoint:(id)sender {
    NSLog(@"set new point");
    undoButton.enabled = YES;
    
    // remove polygon or line
    if (currentDrawMode != POINT) {
        [mapView removeOverlay:overlayView.overlay];
    } else {
        if (pinAnnotation) {
            [mapView removeAnnotation:pinAnnotation];
        }
    }
    
    if (!locationPoints) {
        locationPoints = [[NSMutableArray alloc] init];
    }
    
    MKCoordinateRegion mapRegion = mapView.region;
    LocationPoint *lp = [[LocationPoint alloc] init];
    lp.longitude = mapRegion.center.longitude;
    lp.latitude = mapRegion.center.latitude;
    [locationPoints addObject:lp];
    
    switch (currentDrawMode) {
        case POINT:
        {
            NSLog(@"draw a point");
            [locationPoints removeAllObjects];
            MKCoordinateRegion mapRegion = mapView.region;
            LocationPoint *lp = [[LocationPoint alloc] init];
            lp.longitude = mapRegion.center.longitude;
            lp.latitude = mapRegion.center.latitude;
            [locationPoints addObject:lp];
            [self drawPoint];
            saveButton.enabled = YES;
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
    coordinate.longitude = ((LocationPoint*)locationPoints[0]).longitude;
    coordinate.latitude = ((LocationPoint*)locationPoints[0]).latitude;
    
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
    
    if (locationPoints.count > 1) {
        points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
        
        for (int index = 0; index < locationPoints.count; index++) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
            coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
            MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
            points[index] = newPoint;
        }
        if (customLine) {
            if (!customLine.persisted) {
                customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                [customLine setPersisted:NO];
            } else {
                customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                [customLine setPersisted:YES];
            }
        } else {
            customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
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
    points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
        
    for (int index = 0; index < locationPoints.count; index++) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
        coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
        MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
        points[index] = newPoint;
    }
    
    if (locationPoints.count < 3) {
        if (customLine) {
            if (!customLine.persisted) {
                customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                [customLine setPersisted:NO];
                
            } else {
                customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
                [customLine setPersisted:YES];
            }
            [customLine setType:currentDrawMode];
            [mapView addOverlay:customLine];
        } else {
            customLine = [MKPolyline polylineWithPoints:points count:locationPoints.count];
            [customLine setPersisted:NO];
            [customLine setType:currentDrawMode];
            [mapView addOverlay:customLine];
        }

        undo = NO;
    } else {
        if (customPolygon) {
            if (!customPolygon.persisted) {
                customPolygon = [MKPolygon polygonWithPoints:points count:locationPoints.count];
                [customPolygon setPersisted:NO];
                
            } else {
                customPolygon = [MKPolygon polygonWithPoints:points count:locationPoints.count];
                [customPolygon setPersisted:YES];
            }
            [customPolygon setType:currentDrawMode];
            [mapView addOverlay:customPolygon];
        } else {
            customPolygon = [MKPolygon polygonWithPoints:points count:locationPoints.count];
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
    coordinate.latitude = ((LocationPoint*)locationPoints[0]).latitude;
    coordinate.longitude = ((LocationPoint*)locationPoints[0]).longitude;
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
            [locationPoints removeLastObject];
            saveButton.enabled = NO;
            break;
        }
        case LINE:
        {
            [mapView removeOverlay:overlayView.overlay];
            isOnlyOnePoint = [self deleteStartPoint];
            [locationPoints removeLastObject];

            if (!isOnlyOnePoint) {
                // set hairline cross to the last location
                span.latitudeDelta = 0.005;
                span.longitudeDelta = 0.005;
                cll.latitude = ((LocationPoint*)locationPoints.lastObject).latitude;
                cll.longitude = ((LocationPoint*)locationPoints.lastObject).longitude;
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
            [locationPoints removeLastObject];

            if (!isOnlyOnePoint) {
                // set hairline cross to the last location
                span.latitudeDelta = 0.005;
                span.longitudeDelta = 0.005;
                cll.latitude = ((LocationPoint*)locationPoints.lastObject).latitude;
                cll.longitude = ((LocationPoint*)locationPoints.lastObject).longitude;
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
    
    if (locationPoints.count > 0) {
        undoButton.enabled = YES;
        return;
    }
    undoButton.enabled = NO;
}

- (void) checkForSaving {
    
    switch (currentDrawMode) {
        case POINT: {
            if (locationPoints.count > 0) {
                saveButton.enabled = YES;
            }
            return;
        }
        case LINE:
        {
            if (locationPoints.count > 1) {
                saveButton.enabled = YES;
                return;
            }
            saveButton.enabled = NO;
            break;
        }
        case POLYGON:
        {
            if (locationPoints.count > 2) {
                saveButton.enabled = YES;
                return;
            }
            saveButton.enabled = NO;
            break;
        }
    }
}

- (BOOL) deleteStartPoint {
    if (locationPoints.count == 1) {
        NSLog(@"delete start point");
        [mapView removeAnnotation:customAnnotationView.annotation];
        saveButton.enabled = NO;
        return YES;
    }
    return NO;
}

- (void) showEditModeAppearance {
    hairlinecross.hidden = NO;
    undoButton.hidden = NO;
    setButton.hidden = NO;
    modeButton.hidden = YES;
    undoButton.enabled = NO;
}

- (void) showStartModeAppearance {
    saveButton.enabled = NO;
    hairlinecross.hidden = YES;
    undoButton.hidden = YES;
    setButton.hidden = YES;
    modeButton.hidden = NO;
    cancelButton.enabled = NO;
}

- (void) showFreeHandModeAppearance {
    hairlinecross.hidden = YES;
    undoButton.hidden = NO;
    setButton.hidden = YES;
    modeButton.hidden = YES;
}

- (IBAction)showModeOptions:(id)sender {
    
    if (!modeOptions) {
        modeOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"areaPinMod", nil), NSLocalizedString(@"areaLineMod", nil),/*@"Linie (free-hand)",*/ NSLocalizedString(@"areaPolygonMod", nil), /*@"Polygon (free-hand)",*/ nil];
        
        UIImageView *pinSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, pinY, imgWidht, imgHeight)];
        [pinSymbol setImage:[UIImage imageNamed:@"symbol-pin.png"]];
        [modeOptions addSubview:pinSymbol];
        
        UIImageView *lineSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, lineY, imgWidht, imgHeight)];
        [lineSymbol setImage:[UIImage imageNamed:@"symbol-line.png"]];
        [modeOptions addSubview:lineSymbol];
        
        UIImageView *polygonSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, polyY, imgWidht, imgHeight)];
        [polygonSymbol setImage:[UIImage imageNamed:@"symbol-polygon.png"]];
        [modeOptions addSubview:polygonSymbol];

        modeOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    [modeOptions showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)relocate:(id)sender {
    
    // Register event for handling zooming in on users current position
    [mapView.userLocation addObserver:self
     forKeyPath:@"location"
     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
     context:NULL];
    
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
    cancelButton.enabled = YES;
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
