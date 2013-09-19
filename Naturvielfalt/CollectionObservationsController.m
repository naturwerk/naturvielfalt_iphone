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
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h>

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

extern int UNKNOWN_ORGANISMID;
NaturvielfaltAppDelegate *app;

@implementation CollectionObservationsController
@synthesize observationsToSubmit, table, countObservations, doSubmit, segmentControl, mapView, observationsView, obsToSubmit, checkAllButton, mapSegmentControl, checkAllView, noEntryFoundLabel, persistenceManager, pager, loadingHUD, uploadView;


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
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxCell"];
    
    [self setupTableViewFooter];
    
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // If there aren't any observations in the list. Stop the editing mode.
    if([[paginator results] count] < 1) {
        table.editing = NO;
        table.hidden = YES;
        noEntryFoundLabel.hidden = NO;
    } else {
        table.hidden = NO;
        noEntryFoundLabel.hidden = YES;
    }
    [super paginator:paginator didReceiveResults:results];
    [self reloadAnnotations];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void) reloadAnnotations {
    observationAnnotations = [[NSMutableArray alloc] init];
    
    for (Observation *observation in pager.results) {
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
        if(alertView == uploadView) {
            ((AlertUploadView*) alertView).keepAlive = YES;
            
            alertView.title = NSLocalizedString(@"collectionHudWaitMessage", nil);
            alertView.message = NSLocalizedString(@"collectionHudFinishingRequests", nil);
            
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
        for (Observation *obs in pager.results) {
            obs.submitToServer = YES;
        }
        checkAllButton.tag = 1;
    } else {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox.png"]];
        for (Observation *obs in pager.results) {
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
    
    obsToSubmit = [[NSMutableArray alloc] init];
    for (Observation *obs in pager.results) {
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

    uploadView = [[AlertUploadView alloc] initWithTitle:NSLocalizedString(@"collectionHudWaitMessage", nil) message:NSLocalizedString(@"collectionHudSubmitMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil) otherButtonTitles:nil];

    [uploadView show];
    
    [self sendRequestToServer];
    
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
    
    observationCounter = obsToSubmit.count;
    totalRequests = observationCounter;
    
    if (!observationUploadHelpers) {
        observationUploadHelpers = [[NSMutableArray alloc] init];
    }
    
    for (Observation *obs in obsToSubmit) {
        // single observation
        if(!doSubmit) break;
        if (obs.inventoryId == 0) {
            ObservationUploadHelper *observationUploadHelper = [[ObservationUploadHelper alloc] init];
            [observationUploadHelper registerListener:self];
            [observationUploadHelpers addObject:observationUploadHelper];
            [observationUploadHelper submit:obs withRecursion:NO];
        }
    }
}

- (IBAction)segmentChanged:(id)sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            [UIView transitionWithView:observationsView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                table.hidden = NO;
                noEntryFoundLabel.hidden = [pager.results count] > 0;
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
                noEntryFoundLabel.hidden = YES;
            }completion:nil];
        }
    }
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    if(app.observationsChanged) {
        //new, edited or deleted observations, fetch observations again (show first page)
        table.editing = NO;
        loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
        loadingHUD.mode = MBProgressHUDModeCustomView;
        [pager fetchFirstPage];
        app.observationsChanged = NO;
    }
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
    
    switch (mapType) {
        case 1:{mapView.mapType = MKMapTypeSatellite; [mapSegmentControl setSelectedSegmentIndex:0]; break;}
        case 2:{mapView.mapType = MKMapTypeHybrid; [mapSegmentControl setSelectedSegmentIndex:1]; break;}
        case 3:{mapView.mapType = MKMapTypeStandard; [mapSegmentControl setSelectedSegmentIndex:2]; break;}
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [pager.results removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // If there aren't any observations in the list. Stop the editing mode.
        if([pager.results count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        
        //update map
        [self reloadAnnotations];
        
        //update tablefooter
        pager.total--;
        [self updateTableViewFooter];
    }
}

// MARK: -
// MARK: TableViewDelegate


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
    
    Observation *observation = [pager.results objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        
        if(observation.pictures.count > 0){
            checkboxCell.image.contentMode = UIViewContentModeScaleAspectFit;
            checkboxCell.image.image = ((ObservationImage *)[observation.pictures objectAtIndex:0]).image;
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
    
    for(Observation *ob in pager.results) {
        if(ob.observationId == [number longLongValue]) {
            ob.submitToServer = !ob.submitToServer;
        }
    }
    [table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    if(!organismSubmitController)
    organismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                      initWithNibName:@"ObservationsOrganismSubmitController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Observation *observation = [pager.results objectAtIndex:indexPath.row];
    
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
        uploadView.keepAlive = NO;
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self.table reloadData];
    }
}

@end
