//
//  CollectionAreaObservationsController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 20.06.13.
//
//

#import "CollectionAreaObservationsController.h"
#import "CheckboxAreaObsCell.h"
#import "AreasSubmitController.h"
#import "ObservationsOrganismSubmitController.h"
#import "CustomObservationAnnotation.h"
#import "CustomObservationAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#define pWidth 5
#define pAlpha 0.1

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

extern int UNKNOWN_ORGANISMID;

@implementation CollectionAreaObservationsController
@synthesize table, areaObservationsView, mapView, segmentControl, mapSegmentControl, noEntryFoundLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [self setAreaObservationsView:nil];
    [self setMapView:nil];
    [self setMapSegmentControl:nil];
    [self setNoEntryFoundLabel:nil];
    [self setSegmentControl:nil];
    observations = nil;
    areaObservationAnnotations = nil;
    persistenceManager = nil;
    loadingHUD = nil;
    operationQueue = nil;
    curIndex = nil;
    [super viewDidUnload];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"collectionAreaObsTitle", nil);
    self.navigationItem.title = title;
    
    // Set keys of segment control
    [segmentControl setTitle:NSLocalizedString(@"collectionTableControl", nil) forSegmentAtIndex:0];
    [segmentControl setTitle:NSLocalizedString(@"collectionMapControl", nil) forSegmentAtIndex:1];
    [segmentControl setSelectedSegmentIndex:0];
    
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapSatellite", nil) forSegmentAtIndex:0];
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapHybrid", nil) forSegmentAtIndex:1];
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapStandard", nil) forSegmentAtIndex:2];
    [mapSegmentControl setSelectedSegmentIndex:1];
    
    mapView.delegate = self;
    table.delegate = self;
    
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    // Reload the observations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadAreaObservations) onTarget:self withObject:nil animated:YES];*/

    
    // Reload table
    [table reloadData];
}

- (void) reloadAnnotations {
    areaObservationAnnotations = [[NSMutableArray alloc] init];
    
    for (Observation *observation in observations) {
        CLLocationCoordinate2D cll;
        cll.latitude = observation.location.coordinate.latitude;
        cll.longitude = observation.location.coordinate.longitude;
        CustomObservationAnnotation *obsAnno = [[CustomObservationAnnotation alloc] initWithWithCoordinate:cll type:observation.inventory.area.typeOfArea observation:observation];
        
        [areaObservationAnnotations addObject:obsAnno];
    }
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotations:areaObservationAnnotations];
    [self loadArea];
    [self zoomMapViewToFitAnnotations:YES];
}

- (void)zoomMapViewToFitAnnotations:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void)beginLoadingObservations
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadAreaObservations) object:nil];
    [operationQueue addOperation:operation];
}

- (void)synchronousLoadAreaObservations
{
    NSMutableArray *arrNewObservations;
    @synchronized (self) {
        // Establish a connection
        [persistenceManager establishConnection];
        
        // Get all observations
        arrNewObservations = [persistenceManager getAllAreaObservations];
        
        [persistenceManager closeConnection];
    }
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingAreaObservations:) withObject:arrNewObservations waitUntilDone:YES];
}

- (void)didFinishLoadingAreaObservations:(NSMutableArray *)arrNewObservations
{
    if(observations != nil) {
        if([observations count] != [arrNewObservations count]){
            observations = arrNewObservations;
        }
    }
    else {
        observations = arrNewObservations;
    }
    
    countObservations = (int *)observations.count;
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([observations count] < 1) {
        table.editing = NO;
        table.hidden = YES;
        noEntryFoundLabel.hidden = NO;
    } else {
        table.hidden = NO;
        noEntryFoundLabel.hidden = YES;
    }
    [self reloadAnnotations];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void) reloadAreaObservations
{
    // Reset observations
    observations = nil;
    [self beginLoadingObservations];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = NO;
    loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    loadingHUD.mode = MBProgressHUDModeCustomView;
    [self reloadAreaObservations];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite;
            [mapSegmentControl setSelectedSegmentIndex:0]; break;}
        case 2:{mapView.mapType = MKMapTypeHybrid; [mapSegmentControl setSelectedSegmentIndex:1]; break;}
        case 3:{mapView.mapType = MKMapTypeStandard; [mapSegmentControl setSelectedSegmentIndex:2]; break;}
    }
}

- (IBAction)segmentChanged:(id)sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [UIView transitionWithView:areaObservationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = NO;
                mapView.hidden = YES;
                mapSegmentControl.hidden = YES;
            }completion:nil];
            break;
        }
            
        case 1:
        {
            [UIView transitionWithView:areaObservationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = YES;
                mapView.hidden = NO;
                mapSegmentControl.hidden = NO;
            }completion:nil];
        }
    }
}

- (void) loadArea {
    
    NSMutableDictionary *aToDraw = [[NSMutableDictionary alloc] init];
    //NSMutableArray *areasToDraw = [[NSMutableArray alloc] init];
    [mapView removeOverlays:mapView.overlays];
    for (Observation *obs in observations) {
        Area *area = obs.inventory.area;
        if (/*![areasToDraw containsObject:area]*/ ![aToDraw objectForKey:[NSString stringWithFormat:@"%lli", area.areaId]]) {
            //[areasToDraw addObject:area];
            [aToDraw setObject:area forKey:[NSString stringWithFormat:@"%lli",area.areaId]];
            NSMutableArray *locationPoints = [[NSMutableArray alloc] initWithArray:area.locationPoints];
            
            MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * locationPoints.count);
            CLLocationCoordinate2D coordinate;
            
            for (int index = 0; index < locationPoints.count; index++) {
                coordinate.latitude = ((LocationPoint*)locationPoints[index]).latitude;
                coordinate.longitude = ((LocationPoint*)locationPoints[index]).longitude;
                MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
                points[index] = newPoint;
            }
            
            switch (area.typeOfArea) {
                case POINT:
                {
                    //CustomObservationAnnotation *obsAnno = [[CustomObservationAnnotation alloc] initWithWithCoordinate:coordinate type:area.typeOfArea observation:obs];
                    //MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
                    //anno.coordinate = coordinate;
                    //[mapView addAnnotation:obsAnno];
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
    aToDraw = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxAreaObsCell *cell = (CheckboxAreaObsCell *)[tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [observations removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([observations count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        
        // Reload the observations from the database and refresh the TableView
        //[self reloadAreaObservations];
    }
}


// MARK: -
// MARK: TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [observations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CheckboxAreaObsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout
    CheckboxAreaObsCell *checkboxAreaObsCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxAreaObsCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxAreaObsCell =  (CheckboxAreaObsCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxAreaObsCell = (CheckboxAreaObsCell *)cell;
    }
    
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        
        if(observation.pictures.count > 0){
            UIImage *original = ((ObservationImage *)[observation.pictures objectAtIndex:0]).image;
            CGFloat scale = [UIScreen mainScreen].scale;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef context = CGBitmapContextCreate(NULL, 26, 26, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
            CGContextDrawImage(context,
                               CGRectMake(0, 0, 26, 26 * scale),
                               original.CGImage);
            CGImageRef shrunken = CGBitmapContextCreateImage(context);
            UIImage *final = [UIImage imageWithCGImage:shrunken];
            
            CGContextRelease(context);
            CGImageRelease(shrunken);
            checkboxAreaObsCell.image.image = final;
        }
        else {
            checkboxAreaObsCell.image.image = [UIImage imageNamed:@"blank.png"];
        }
        
        if (observation.organism.organismId == UNKNOWN_ORGANISMID) {
            checkboxAreaObsCell.name.text = NSLocalizedString(@"unknownOrganism", nil);
            checkboxAreaObsCell.latName.text = NSLocalizedString(@"toBeDetermined", nil);
            checkboxAreaObsCell.name.textColor = [UIColor grayColor];
            checkboxAreaObsCell.latName.textColor = [UIColor grayColor];
        } else {
            checkboxAreaObsCell.name.text = [observation.organism getName];
            checkboxAreaObsCell.latName.text = [observation.organism getLatName];
            checkboxAreaObsCell.name.textColor = [UIColor blackColor];
            checkboxAreaObsCell.latName.textColor = [UIColor blackColor];
        }

        
        checkboxAreaObsCell.date.text = nowString;
        checkboxAreaObsCell.amount.text = observation.amount;
        checkboxAreaObsCell.areaImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:observation.inventory.area]]];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaObsCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaObsCell.checkbox setTag:observation.observationId];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaObsCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaObsCell.remove setTag:observation.observationId];
        
        if (observation.submitted) {
            checkboxAreaObsCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxAreaObsCell.submitted.hidden = NO;
            checkboxAreaObsCell.submitted.text = NSLocalizedString(@"navSubmitted", nil);
            [checkboxAreaObsCell.amount setAlpha:0.4f];
            [checkboxAreaObsCell.date setAlpha:0.4f];
            [checkboxAreaObsCell.image setAlpha:0.4f];
            //checkboxAreaObsCell.checkbox.hidden = YES;
            observation.submitToServer = NO;
        } else {
            checkboxAreaObsCell.contentView.backgroundColor = [UIColor clearColor];
            checkboxAreaObsCell.submitted.hidden = YES;
            [checkboxAreaObsCell.amount setAlpha:1];
            [checkboxAreaObsCell.date setAlpha:1];
            [checkboxAreaObsCell.image setAlpha:1];
            observation.submitToServer = YES;
        }
        
        // Set checkbox icon
        /*if(observation.submitToServer) {
            checkboxAreaObsCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxAreaObsCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }*/
    }
    
    checkboxAreaObsCell.layer.shouldRasterize = YES;
    checkboxAreaObsCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return checkboxAreaObsCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Observation *ob in observations) {
        if(ob.observationId == [number longLongValue]) {
            ob.submitToServer = !ob.submitToServer;
        }
    }
    
    [table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                      initWithNibName:@"ObservationsOrganismSubmitController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    // Store the current observation object
    /*Observation *observationShared = [[Observation alloc] getObservation];
     [observationShared setObservation:observation];
     
     NSLog(@"Observation in CollectionOverView: %@", [observationShared getObservation]);*/
    
    // Set the current displayed organism
    organismSubmitController.observation = observation;
    organismSubmitController.organism = observation.organism;
    organismSubmitController.review = YES;
    organismSubmitController.organismGroup = observation.organismGroup;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:YES];
    organismSubmitController = nil;
}

#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"mapView viewForAnnotation");
    
    // return nil, if annotation is user location
    if ([annotation class] == MKUserLocation.class) {
        return nil;
    }
    
    CustomObservationAnnotation *observationAnnotation = (CustomObservationAnnotation*) annotation;
    
    NSString *identifier = @"AnnotationId";
    CustomObservationAnnotationView *newAnnotationView = (CustomObservationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    newAnnotationView = [[CustomObservationAnnotationView alloc] initWithAnnotation:observationAnnotation  navigationController:self.navigationController observationsOrganismSubmitController:nil reuseIdentifier:identifier];
    CustomObservationAnnotationView *customObservationAnnotationView = newAnnotationView;
    [customObservationAnnotationView setEnabled:YES];
    
    return customObservationAnnotationView;
}

#pragma MKMapViewDelegate methods
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



- (IBAction)mapSegmentChanged:(id)sender {
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    switch (mapSegmentControl.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"satelite");
            mapView.mapType = MKMapTypeSatellite;
            [appSettings setObject:@"1" forKey:@"mapType"];
            break;
        }
        case 1:
        {
            NSLog(@"hybride");
            mapView.mapType = MKMapTypeHybrid;
            [appSettings setObject:@"2" forKey:@"mapType"];
            break;
        }
        case 2:
        {
            NSLog(@"map");
            mapView.mapType = MKMapTypeStandard;
            [appSettings setObject:@"3" forKey:@"mapType"];
            break;
        }
    }
}
@end
