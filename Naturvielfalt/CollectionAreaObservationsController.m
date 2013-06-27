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

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

@implementation CollectionAreaObservationsController
@synthesize table, persistenceManager, observations, operationQueue, countObservations, curIndex, areaObservationsView, mapView, segmentControl;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [self setAreaObservationsView:nil];
    [self setMapView:nil];
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
    NSArray *keys = [NSArray arrayWithObjects:NSLocalizedString(@"collectionTableControl", nil), NSLocalizedString(@"collectionMapControl", nil), nil];
    segmentControl = [[UISegmentedControl alloc] initWithItems:keys];
    segmentControl.frame = CGRectMake(83, 3, 155, 44);
    segmentControl.selectedSegmentIndex = 0;
    segmentControl.transform = CGAffineTransformMakeScale(.7f, .7f);
    
    [segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:segmentControl];

    mapView.delegate = self;
    table.delegate = self;
    
    // Reload the observations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadObservations) onTarget:self withObject:nil animated:YES];
    
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
    
    countObservations = (int *)self.observations.count;
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([observations count] < 1) {
        table.editing = FALSE;
    }
    [self reloadAnnotations];
}

- (void) reloadObservations
{
    // Reset observations
    observations = nil;
    [self beginLoadingObservations];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = FALSE;
    [self reloadObservations];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite;break;}
        case 2:{mapView.mapType = MKMapTypeHybrid;break;}
        case 3:{mapView.mapType = MKMapTypeStandard;break;}
    }
}

- (IBAction)segmentChanged:(id)sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [UIView transitionWithView:areaObservationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = NO;
                mapView.hidden = YES;
            }completion:nil];
            break;
        }
            
        case 1:
        {
            [UIView transitionWithView:areaObservationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = YES;
                mapView.hidden = NO;
            }completion:nil];
        }
    }
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
        self.curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        // Reload the observations from the database and refresh the TableView
        [self reloadObservations];
    }
}


// MARK: -
// MARK: TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.observations count];
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
        
        checkboxAreaObsCell.name.text = [observation.organism getNameDe];
        checkboxAreaObsCell.date.text = nowString;
        checkboxAreaObsCell.amount.text = observation.amount;
        checkboxAreaObsCell.latName.text = [observation.organism getLatName];
        checkboxAreaObsCell.areaImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:observation.inventory.area]]];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaObsCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaObsCell.checkbox setTag:observation.observationId];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaObsCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaObsCell.remove setTag:observation.observationId];
        
        if (observation.inventory.area.submitted) {
            checkboxAreaObsCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxAreaObsCell.submitted.hidden = NO;
            [checkboxAreaObsCell.amount setAlpha:0.2f];
            [checkboxAreaObsCell.date setAlpha:0.2f];
            [checkboxAreaObsCell.image setAlpha:0.2f];
            //checkboxAreaObsCell.checkbox.hidden = YES;
            observation.submitToServer = NO;
        }
        
        // Set checkbox icon
        /*if(observation.submitToServer) {
            checkboxAreaObsCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxAreaObsCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }*/
    }
    
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
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
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



@end
