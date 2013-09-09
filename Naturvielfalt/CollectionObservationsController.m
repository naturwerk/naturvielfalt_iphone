//
//  CollectionOverviewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionObservationsController.h"
#import "CheckboxCell.h"
#import "ObservationsOrganismSubmitController.h"
#import "CustomObservationAnnotation.h"
#import "CustomObservationAnnotationView.h"
#import "AreasSubmitController.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h>

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

extern int UNKNOWN_ORGANISMID;

@implementation CollectionObservationsController
@synthesize observations, persistenceManager, observationsToSubmit, table, countObservations, queue, operationQueue, curIndex, doSubmit, segmentControl, mapView, observationsView, obsToSubmit, checkAllButton, mapSegmentControl, checkAllView, noEntryFoundLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        doSubmit = NO;
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setSegmentControl:nil];
    [self setMapView:nil];
    [self setObservationsView:nil];
    [self setCheckAllButton:nil];
    mapSegmentControl = nil;
    [self setCheckAllView:nil];
    [self setNoEntryFoundLabel:nil];
    [super viewDidUnload];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"observationTabLabel", nil);
    self.navigationItem.title = title;
    
    // Set keys of segment control
    [segmentControl setTitle:NSLocalizedString(@"collectionTableControl", nil) forSegmentAtIndex:0];
    [segmentControl setTitle:NSLocalizedString(@"collectionMapControl", nil) forSegmentAtIndex:1];
    [segmentControl setSelectedSegmentIndex:0];
    
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapSatellite", nil) forSegmentAtIndex:0];
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapHybrid", nil) forSegmentAtIndex:1];
    [mapSegmentControl setTitle:NSLocalizedString(@"settingsMapStandard", nil) forSegmentAtIndex:2];
    [mapSegmentControl setSelectedSegmentIndex:1];
    
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navSubmit", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(alertOnSendObservationsDialog)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    
    mapView.delegate = self;
    
    [checkAllButton setTag:1];
    
    // Create filter button and add it to the NavigationBar
    /*UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"navDel", nil)
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action: @selector(removeObservations)];
    
    self.navigationItem.leftBarButtonItem = editButton;*/
    
    // Reload the observations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    [self.navigationController.view addSubview:loadingHUD];
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadObservations) onTarget:self withObject:nil animated:YES];*/
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxCell"];
    
    // Reload table
    [table reloadData];
}

- (void) reloadAnnotations {
    observationAnnotations = [[NSMutableArray alloc] init];
    
    for (Observation *observation in observations) {
        CLLocationCoordinate2D cll;
        cll.latitude = observation.location.coordinate.latitude;
        cll.longitude = observation.location.coordinate.longitude;
        CustomObservationAnnotation *obsAnno = [[CustomObservationAnnotation alloc] initWithWithCoordinate:cll type:observation.inventory.area.typeOfArea observation:observation];
    
        [observationAnnotations addObject:obsAnno];
    }
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotations:observationAnnotations];
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

//Check if there is an active WiFi connection
- (BOOL) connectedToWiFi{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = NO;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = YES;
	}
	
	return result;
}

//Check if there is an active internet connection (3G OR WIFI)
- (BOOL) connectedToInternet{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = false;
	
	if (internetStatus != NotReachable)
	{
	    result = true;
	}
	
	return result;
}


//fires an alert if not connected to WiFi
- (void) alertOnSendObservationsDialog{
    doSubmit = TRUE;
    if(![self connectedToInternet]) {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertNoInternetTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertNoInternetDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)
                                                    otherButtonTitles:nil , nil];
        [submitAlert show];
    }
    else if([self connectedToWiFi]){
        [self sendObservations];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertObsTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertObsDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(doSubmit){
        if([alertView.title isEqualToString:NSLocalizedString(@"collectionAlertObsTitle", nil)]) {
            if (buttonIndex == 1){
                [self sendObservations];
            } else{
                for (ObservationUploadHelper *ouh in observationUploadHelpers) {
                    [ouh cancel];
                }
            }
        }
        doSubmit = NO;
    }
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

- (IBAction)checkAllObs:(id)sender {
    int currentTag = checkAllButton.tag;
    
    if (currentTag == 0) {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];
        for (Observation *obs in observations) {
            obs.submitToServer = YES;
        }
        checkAllButton.tag = 1;
    } else {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox.png"]];
        for (Observation *obs in observations) {
            obs.submitToServer = NO;
        }
        checkAllButton.tag = 0;
    }
    [table reloadData];
}

- (void) sendObservations
{
    
    // Get username and password from the UserDefaults
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [appSettings stringForKey:@"username"];
    NSString *password = [appSettings stringForKey:@"password"];
    
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil)
                                                              message:NSLocalizedString(@"collectionAlertErrorSettings", nil) delegate:self cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
        return;
    }
    
    uploadView = [[AlertUploadView alloc] initWithTitle:NSLocalizedString(@"collectionHudWaitMessage", nil) message:NSLocalizedString(@"collectionHudSubmitMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil) otherButtonTitles:nil];
    /*UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
     pv.frame = CGRectMake(40, 67, 200, 15);
     CGAffineTransform myTransform = CGAffineTransformMakeScale(1.0, 2.0f);
     pv.progress = 0.5;
     [uploadView addSubview:pv];*/
    [uploadView show];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
     [self.navigationController.view addSubview:loadingHUD];
     
     loadingHUD.delegate = self;
     loadingHUD.mode = MBProgressHUDModeCustomView;
     loadingHUD.labelText = NSLocalizedString(@"collectionHudWaitMessage", nil);
     loadingHUD.detailsLabelText = NSLocalizedString(@"collectionHudSubmitMessage", nil);
     
     //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     [loadingHUD show:YES];*/
    [self sendRequestToServer];
    
    //[loadingHUD showWhileExecuting:@selector(sendRequestToServer) onTarget:self withObject:nil animated:YES];
}

- (void) sendRequestToServer
{
    // check username and password from the UserDefaults
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    if([appSettings objectForKey:@"username"] == nil || [appSettings objectForKey:@"password"] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorSettings", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    //new portal
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    
    obsToSubmit = [[NSMutableArray alloc] init];
    for (Observation *obs in observations) {
        if (obs.submitToServer) {
            [obsToSubmit addObject:obs];
        }
    }
    observationCounter = obsToSubmit.count;
    totalRequests = observationCounter;
    
    if(observationCounter == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorObs", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (!observationUploadHelpers) {
        observationUploadHelpers = [[NSMutableArray alloc] init];
    }
    
    for (Observation *obs in obsToSubmit) {
        // single observation
        if (obs.inventoryId == 0) {
            ObservationUploadHelper *observationUploadHelper = [[ObservationUploadHelper alloc] init];
            [observationUploadHelper registerListener:self];
            [observationUploadHelpers addObject:observationUploadHelper];
            [observationUploadHelper submit:obs withRecursion:NO];
        }
    }
}

- (void) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request {
    
    /*AsyncRequestDelegate *asyncDelegate = [[AsyncRequestDelegate alloc] initWithObject:ob];
    [asyncDelegate registerListener:self];
    request.delegate = asyncDelegate;
    [asyncDelegates addObject:asyncDelegate];
    
    [request startAsynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        
        NSLog(@"Response: '%@'", response);
        
        if([response isEqualToString:@"SUCCESS"]) {
            
            // And Delete the observation form the database
            [persistenceManager establishConnection];
            [persistenceManager deleteObservation:ob.observationId];
            [persistenceManager closeConnection];
            // Reload observations
            [self reloadObservations];
            return true;
        }
        return false;
    } else {
        return false;
    }*/
}

- (IBAction)segmentChanged:(id)sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [UIView transitionWithView:observationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = NO;
                mapView.hidden = YES;
                mapSegmentControl.hidden = YES;
                checkAllButton.hidden = NO;
            }completion:nil];
            break;
        }
            
        case 1:
        {
            [UIView transitionWithView:observationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = YES;
                mapView.hidden = NO;
                mapSegmentControl.hidden = NO;
                checkAllButton.hidden = YES;
            }completion:nil];
        }
    }
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void)beginLoadingObservations
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadObservations) object:nil];
    [operationQueue addOperation:operation];
}

- (void)synchronousLoadObservations
{
    NSMutableArray *arrNewObservations;
    @synchronized (self) {
        // Establish a connection
        [persistenceManager establishConnection];
        
        // Get all observations
        arrNewObservations = [persistenceManager getAllSingelObservations];
        
        [persistenceManager closeConnection];
    }
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingObservations:) withObject:arrNewObservations waitUntilDone:YES];
}

- (void)didFinishLoadingObservations:(NSMutableArray *)arrNewObservations
{
    if(observations != nil) {
        if([observations count] != [arrNewObservations count]){
            observations = arrNewObservations;
        }
    }
    else {
        observations = arrNewObservations;
    }
    
    countObservations = self.observations.count;
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curIndex] withRowAnimation:YES];
    
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

- (void) reloadObservations
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
    [self reloadObservations];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite; [mapSegmentControl setSelectedSegmentIndex:0]; break;}
        case 2:{mapView.mapType = MKMapTypeHybrid; [mapSegmentControl setSelectedSegmentIndex:1]; break;}
        case 3:{mapView.mapType = MKMapTypeStandard; [mapSegmentControl setSelectedSegmentIndex:2]; break;}
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
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
        
        // If there aren't any observations in the list. Stop the editing mode.
        if([observations count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        
        // Reload the observations from the database and refresh the TableView
        //[self reloadObservations];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell" forIndexPath:indexPath];
    
    // use CustomCell layout
    CheckboxCell *checkboxCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxCell" owner:self options:nil];
        
        checkboxCell =  (CheckboxCell *)topLevelObjects[0];

    } else {
        checkboxCell = (CheckboxCell *)cell;
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
            checkboxCell.image.image = final;
        }
        else {
            checkboxCell.image.image = [UIImage imageNamed:@"blank.png"];
        }
        
        if (observation.organism.organismId == UNKNOWN_ORGANISMID) {
            //checkboxCell.name.text = NSLocalizedString(@"unknownOrganism", nil);
            //checkboxCell.latName.text = NSLocalizedString(@"toBeDetermined", nil);
            checkboxCell.name.textColor = [UIColor grayColor];
            checkboxCell.latName.textColor = [UIColor grayColor];
        } else {
            checkboxCell.name.textColor = [UIColor blackColor];
            checkboxCell.latName.textColor = [UIColor blackColor];
        }

        checkboxCell.name.text = [observation.organism getName];
        checkboxCell.latName.text = [observation.organism getLatName];
        checkboxCell.date.text = nowString;
        checkboxCell.amount.text = observation.amount;
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.checkbox setTag:observation.observationId];
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.remove setTag:observation.observationId];
        
        if (observation.submitted) {
            checkboxCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxCell.submitted.hidden = NO;
            checkboxCell.submitted.text = NSLocalizedString(@"navSubmitted", nil);
            [checkboxCell.amount setAlpha:0.4f];
            [checkboxCell.date setAlpha:0.4f];
            [checkboxCell.image setAlpha:0.4f];
            checkboxCell.checkbox.hidden = YES;
            checkboxCell.checkboxView.hidden = YES;
            observation.submitToServer = NO;
        } else {
            checkboxCell.contentView.backgroundColor = [UIColor clearColor];
            checkboxCell.submitted.hidden = YES;
            [checkboxCell.amount setAlpha:1];
            [checkboxCell.date setAlpha:1];
            [checkboxCell.image setAlpha:1];
            checkboxCell.checkbox.hidden = NO;
            checkboxCell.checkboxView.hidden = NO;
            //area.submitToServer = YES;
        }

    
        // Set checkbox icon
        if(observation.submitToServer) {
            //checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
            [checkboxCell.checkboxView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];
        } else {
            //checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.png"];
            [checkboxCell.checkboxView setImage:[UIImage imageNamed:@"checkbox.png"]];
        }
    }
    
    checkboxCell.layer.shouldRasterize = YES;
    checkboxCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return checkboxCell;
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


# pragma Listener methods
- (void)notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer>)observer {
    [observer unregisterListener];
    if (object.class != [Observation class]) {
        return;
    }
    Observation *observation = (Observation *) object;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    float percent = (100 / totalRequests) * (totalRequests - (--observationCounter));
    NSLog(@"requestcounter: %d progress: %f",observationCounter + 1,  percent / 100);
    uploadView.progressView.progress = percent / 100;
    
    //Save received guid in object, not persisted yet
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
    NSString *successString;
    if ([matches count] > 0) {
        successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
    } else {
        NSLog(@"ERROR: NO GUID received!! response: %@", response);
    }
    
    if ([successString isEqualToString:@"success=1"]) {
        // Reload observations
        [obsToSubmit removeObject:observation];
    }
    
    if (observationCounter == 0) {
        [observationUploadHelpers removeAllObjects];
        
        if (obsToSubmit.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navSuccess", nil) message:NSLocalizedString(@"collectionSuccessObsDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [obsToSubmit removeAllObjects];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorObsSubmit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
            [alert show];
        }
        //[loadingHUD removeFromSuperview];
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self reloadObservations];
    }
}

@end
