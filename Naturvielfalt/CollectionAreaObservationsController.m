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
#import "NaturvielfaltAppDelegate.h"

#define pWidth 5
#define pAlpha 0.1

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

extern int UNKNOWN_ORGANISMID;
NaturvielfaltAppDelegate *app;

@implementation CollectionAreaObservationsController
@synthesize table, areaObservationsView, mapView, segmentControl, mapSegmentControl, pager, persistenceManager, loadingHUD, noEntryFoundLabel;

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
    areaObservationAnnotations = nil;
    persistenceManager = nil;
    loadingHUD = nil;
    [super viewDidUnload];
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
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxAreaObsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxAreaObsCell"];
    
    [self setupTableViewFooter];
}


- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // If there aren't any observations in the list. Stop the editing mode.
    if([self.pager.results count] < 1) {
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
    areaObservationAnnotations = [[NSMutableArray alloc] init];
    
    for (Observation *observation in pager.results) {
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

- (void) viewWillAppear:(BOOL)animated
{
    if(app.areaObservationsChanged) {
        table.editing = NO;
        loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
        loadingHUD.mode = MBProgressHUDModeCustomView;
        [pager fetchFirstPage];
        app.areaObservationsChanged = NO;
    }
    
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
                noEntryFoundLabel.hidden = [pager.results count] > 0;
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
                noEntryFoundLabel.hidden = YES;
                mapSegmentControl.hidden = NO;
                noEntryFoundLabel.hidden = YES;
            }completion:nil];
        }
    }
}

- (void) loadArea {
    areasToDraw = [[NSMutableDictionary alloc] init];
    
    [mapView removeOverlays:mapView.overlays];
    for (Observation *obs in pager.results) {
        Area *area = obs.inventory.area;
            //[areasToDraw addObject:area];
            [areasToDraw setObject:area forKey:[NSString stringWithFormat:@"%lli",area.areaId]];
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
            free(points);
        }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        Observation *obs = [pager.results objectAtIndex:indexPath.row];
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:obs.observationId];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [pager.results removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([pager.results count] < 1) {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxAreaObsCell" forIndexPath:indexPath];
    
    // use CustomCell layout
    CheckboxAreaObsCell *checkboxAreaObsCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxAreaObsCell" owner:self options:nil];

        checkboxAreaObsCell =  (CheckboxAreaObsCell *)topLevelObjects[0];
    } else {
        checkboxAreaObsCell = (CheckboxAreaObsCell *)cell;
    }
    
    Observation *observation = [pager.results objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        
        if(observation.pictures.count > 0){
            checkboxAreaObsCell.image.contentMode = UIViewContentModeScaleAspectFit;
            checkboxAreaObsCell.image.image = ((ObservationImage *)[observation.pictures objectAtIndex:0]).image;
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
    CustomObservationAnnotationView *customObservationAnnotationView = (CustomObservationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!customObservationAnnotationView) {
         customObservationAnnotationView = [[CustomObservationAnnotationView alloc] initWithAnnotation:observationAnnotation  navigationController:self.navigationController observationsOrganismSubmitController:nil reuseIdentifier:identifier];
    }
   
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
