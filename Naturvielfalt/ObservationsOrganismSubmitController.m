//
//  ObservationsOrganismSubmitController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 11.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismSubmitController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomCell.h"
#import "DeleteCell.h"
#import "ObservationsOrganismSubmitMapController.h"
#import "AreasSubmitNewInventoryController.h"
#import "CameraViewController.h"
#import "ObservationsOrganismSubmitAmountController.h"
#import "ObservationsOrganismSubmitCommentController.h"
#import "MBProgressHUD.h"

@implementation ObservationsOrganismSubmitController
@synthesize nameDe, nameLat, organism, observation, tableView, arrayKeys, arrayValues, accuracyImage, locationManager, accuracyText, family, persistenceManager, review, observationChanged, comeFromOrganism, persistedObservation, inventory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidDisappear:(BOOL)animated {
    [observation setObservation:nil];
    [inventory setInventory:nil];
}

- (void) viewDidAppear:(BOOL)animated 
{
    NSLog(@"didAppear");
    
    if (observation.observationId) {
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        
        [persistenceManager establishConnection];
        persistedObservation = [persistenceManager getObservation:observation.observationId];
        Area *currentArea = [persistenceManager getArea:persistedObservation.inventory.areaId];
        [persistenceManager closeConnection];
        
        if (persistedObservation) {
            persistedObservation.inventory.area = currentArea;
            observation = persistedObservation;
        } else {
            [observation setObservation:nil];
            observation = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    } else if (inventory){
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        
        [persistenceManager establishConnection];
        Area *tmpArea = [persistenceManager getArea:inventory.areaId];
        inventory = [persistenceManager getInventory:inventory.inventoryId];
        inventory.area = tmpArea;
        [persistenceManager closeConnection];
        
        if (inventory) {
            observation.inventory = inventory;
            observation.locationLocked = YES;
        } else {
            [inventory setInventory:nil];
            inventory = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self prepareData];
    }
    [tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //just start locationmanager for first run
    if(!observation.locationLocked && !review){
        // Start locationManager
        locationManager = [[CLLocationManager alloc] init];
        
        if ([CLLocationManager locationServicesEnabled]) {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = 10.0f;
            
            //if(!review)
                [locationManager startUpdatingLocation];
        }
    }
    
    if(!comeFromOrganism) comeFromOrganism = false;
    
    // Do any additional setup after loading the view from its nib.
    nameDe.text = [organism getNameDe];
    nameLat.text = (organism.organismGroupId == 1000) ? @"" : [organism getLatName];
    family.text = organism.family;
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:(!review) ? NSLocalizedString(@"navSave", nil)
                                                            : NSLocalizedString(@"navChange", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveObservation)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button  
    UIBarButtonItem *chancelButton = [[UIBarButtonItem alloc] 
                                      initWithTitle:NSLocalizedString(@"navCancel", nil)
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortObservation)];
    self.navigationItem.leftBarButtonItem = chancelButton;
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"observationNavTitle", nil);
    self.navigationItem.title = title;
        
    // Table init
    tableView.delegate = self;
    
    [self prepareData];
    
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    if(!review) {
        // Reset values
        observation.amount = @"1";
        //observation.accuracy = 0;
        observation.comment = @"";
        observation.pictures = pictures;
        observation.locationLocked = false;
    } else {
        [self updateAccuracyIcon: (int)observation.accuracy];
        [tableView reloadData];
    }
    //observationChanged = true;
}

- (void) prepareData 
{
    // Create new observation object, will late be used as data transfer object
    if(!observation) {
        observation = [[Observation alloc]getObservation];
        observation.inventory = inventory;
    }

    
    NSString *nowString;
    
    if(!review) {
        
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        NSString *username = @"";
        
        if([appSettings objectForKey:@"username"] != nil) {
            username = [appSettings stringForKey:@"username"];
        }
        
        observation.organism = organism;
        observation.author = username;
        
        // Set current time
        NSDate *now = [NSDate date];

        // Update date in observation data object
        observation.date = now;
        
        // Set Observation location of first point of area if area is available
        if (observation.inventory) {
            LocationPoint *locationPoint = ((LocationPoint *)[observation.inventory.area.locationPoints objectAtIndex:0]);
            CLLocation *location = [[CLLocation alloc] initWithLatitude:locationPoint.latitude longitude:locationPoint.longitude];
            observation.location = location;
            
            // Save the new location for de map controller if observation has an idea
            if (observation.observationId) {
                [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
            }
        }
        //review = true;
    }
     
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:observation.date];
      
    // Initialize keys/valu es
    arrayKeys = [[NSArray alloc] initWithObjects:NSLocalizedString(@"observationTime", nil), NSLocalizedString(@"observationAuthor", nil), NSLocalizedString(@"observationCtn", nil), NSLocalizedString(@"observationDescr", nil), NSLocalizedString(@"observationImg", nil), NSLocalizedString(@"observationAcc", nil), nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, observation.author, observation.amount, @">", nil];
}

- (void) saveObservation 
{
    if (observation.inventory) {
        observation.inventory.area.submitted = NO;
    }
    
    [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.parentViewController.view];
    [self.navigationController.parentViewController.view addSubview:hud];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.customView = image;
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    //hud.delegate = self;
    hud.labelText = NSLocalizedString(@"observationSuccessMessage", nil);
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"navChange", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveObservation)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];
    //[hud hide:true];
    
    /*[observation setObservation:nil];
    [inventory setObservations:nil];*/
    
    if(comeFromOrganism){
        //TODO go back to the artgroup
    }
    [self.navigationController popViewControllerAnimated:TRUE];
}

+ (void) persistObservation:(Observation *)obsToSave inventory:(Inventory *) ivToSave {
    
    PersistenceManager *pm = [[PersistenceManager alloc] init];
    [pm establishConnection];
    
    // Area feature if inventory object is set
    /*if (ivToSave) {
        //Do not persist, if inventory is cancelled later.
        //Observation Object will be persisted together with the inventory object.
        obsToSave.inventory = ivToSave;
        // No duplicates, so remove if contains
        [ivToSave.observations removeObject:obsToSave];
        [ivToSave.observations addObject:obsToSave];
        
        [AreasSubmitNewInventoryController persistInventory:ivToSave area:ivToSave.area];
        
        if (ivToSave.inventoryId) {
            if (obsToSave.observationId) {
                [pm updateObservation:obsToSave];
            } else {
                obsToSave.observationId = [pm saveObservation:obsToSave];
                for (ObservationImage *oImg in obsToSave.pictures) {
                    oImg.observationId = obsToSave.observationId;
                    oImg.observationImageId = [pm saveObservationImage:oImg];
                }
            }
        }
    } else {*/
        // Save and persist observation
        if(obsToSave.observationId) {
            [pm deleteObservationImagesFromObservation:obsToSave.observationId];
            [pm updateObservation:obsToSave];
        } else {
            obsToSave.observationId = [pm saveObservation:obsToSave];
            for (ObservationImage *oImg in obsToSave.pictures) {
                oImg.observationId = obsToSave.observationId;
                oImg.observationImageId = [pm saveObservationImage:oImg];
            }
        }
    //}
    
    // Close connection
    [pm closeConnection];
}

- (void) abortObservation
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    if(locationManager){
        [locationManager stopUpdatingLocation];
         locationManager = nil;
    }
    //[observation setObservation:nil];
}

- (void) dealloc 
{    
    if(locationManager){
        [locationManager stopUpdatingLocation];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange)range replacementText: (NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) updateAccuracyIcon:(int)accuracyValue {
    UIImage *green = [UIImage imageNamed:@"status-green.png"];
    UIImage *orange = [UIImage imageNamed:@"status-orange.png"];
    UIImage *red = [UIImage imageNamed:@"status-red.png"];
    
    if(accuracyValue <= 30) {
        accuracyImage = green;
    } else if(accuracyValue < 90) {
        accuracyImage = orange;
    } else {
        accuracyImage = red;
    }
    accuracyText = [[NSString alloc] initWithFormat:@"%dm", accuracyValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (observation.observationId) {
        return 2;
    }
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [arrayKeys count];
    }
    return 1;
}

#pragma mark
#pragma mark CLLocationManagerDelegate Methods
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if(!observation.locationLocked && !review && observation.inventory == nil) {
        if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] > 8)
            NSLog(@"LocationManager timeout");
        else if ((newLocation.horizontalAccuracy <= manager.desiredAccuracy) && (newLocation.verticalAccuracy <= manager.desiredAccuracy))
            NSLog(@"Desired accuracy reached!");
        
        
        // Update the Accuracy Image
        [self updateAccuracyIcon: (int)newLocation.horizontalAccuracy];

        // update the observation data object
        //if (!observation.inventory) {
            observation.location = newLocation;
            observation.accuracy = (int)newLocation.horizontalAccuracy;
            NSLog( @"set new location from locationmanager; accuracy: %d", observation.accuracy);
        //}
    } else {
        // Update the Accuracy Image
        //observation.accuracy = observation.location.horizontalAccuracy;
        [self updateAccuracyIcon: (int)observation.accuracy];
    } 
    
    // reload the table with the new data
    [tableView reloadData];
}

// MARK: -
// MARK: TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:nil];
    DeleteCell *deleteCell;
    
    if (indexPath.section == 0) {
        if(indexPath.row > 1) {
            // use CustomCell layout
            CustomCell *customCell;
            
            if(cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                
                for (id currentObject in topLevelObjects){
                    if ([currentObject isKindOfClass:[UITableViewCell class]]){
                        customCell =  (CustomCell *)currentObject;
                        break;
                    }
                }
                
                switch(indexPath.row) {
                    case 2:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = observation.amount;
                        customCell.image.image = nil;
                    }
                        break;
                        
                    case 3:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (observation.comment.length > 0) ? @"..." : @"";
                        customCell.image.image = nil;
                    }
                        break;
                        
                    case 4:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        
                        NSString *picCount = [[NSString alloc] initWithFormat:@"%d", observation.pictures.count];
                        
                        customCell.value.text = picCount;
                        customCell.image.image = nil;
                        
                    }
                        break;
                        
                    case 5:
                    {
                        [self updateAccuracyIcon:observation.accuracy];
                        
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.image.image = accuracyImage; // --------->
                        customCell.value.text = accuracyText;
                    }
                        break;
                        
                    default:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = @"";
                        customCell.image.image = nil;
                    }
                        break;
                }
                
                return customCell;
            }
        } else {
            // Use normal cell layout
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            }
            
            // Set up the cell...
            cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];        
            cell.detailTextLabel.text = [arrayValues objectAtIndex:indexPath.row];
        }
    } else if (indexPath.section == 1){
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DeleteCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    deleteCell =  (DeleteCell *)currentObject;
                    break;
                }
            }
            deleteCell.deleteLabel.text = NSLocalizedString(@"areaObservationDelete", nil);
            return deleteCell;
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    
    currIndexPath = indexPath;
    
    if (indexPath.section == 0) {
        // TODO: rewrite to switch case!
        if (indexPath.row == 2) {
            // AMOUNT
            // Create the ObservationsOrganismSubmitCameraController
            ObservationsOrganismSubmitAmountController *organismSubmitAmountController = [[ObservationsOrganismSubmitAmountController alloc]
                                                                                          initWithNibName:@"ObservationsOrganismSubmitAmountController"
                                                                                          bundle:[NSBundle mainBundle]];
            
            
            organismSubmitAmountController.observation = observation;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitAmountController animated:TRUE];
            organismSubmitAmountController = nil;
            
        }  else if (indexPath.row == 3) {
            // COMMENT
            // Create the ObservationsOrganismSubmitCommentController
            ObservationsOrganismSubmitCommentController *organismSubmitCommentController = [[ObservationsOrganismSubmitCommentController alloc]
                                                                                            initWithNibName:@"ObservationsOrganismSubmitCommentController"
                                                                                            bundle:[NSBundle mainBundle]];
            
            organismSubmitCommentController.observation = observation;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitCommentController animated:TRUE];
            organismSubmitCommentController = nil;
            
        } else if (indexPath.row == 4) {
            // CAMERA
            // Create the ObservationsOrganismSubmitCameraController
            CameraViewController *organismSubmitCameraController = [[CameraViewController alloc]
                                                                    initWithNibName:@"CameraViewController"
                                                                    bundle:[NSBundle mainBundle]];
            
            
            organismSubmitCameraController.observation = observation;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitCameraController animated:TRUE];
            organismSubmitCameraController = nil;
            
        } else if(indexPath.row == 5) {
            // MAP
            // Create the ObservationsOrganismSubmitMapController
            ObservationsOrganismSubmitMapController *organismSubmitMapController = [[ObservationsOrganismSubmitMapController alloc]
                                                                                    initWithNibName:@"ObservationsOrganismSubmitMapController"
                                                                                    bundle:[NSBundle mainBundle]];
            
            organismSubmitMapController.observation = observation;
            
            NSLog(@"longi: %f and lati: %f", observation.location.coordinate.longitude, observation.location.coordinate.latitude);
            
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitMapController animated:TRUE];
            organismSubmitMapController = nil;
        }
    } else if (indexPath.section == 1){
        if (!deleteObservationSheet) {
            deleteObservationSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:NSLocalizedString(@"areaObservationDelete", nil) otherButtonTitles: nil];
            
            deleteObservationSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        [deleteObservationSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

#pragma mark
#pragma UIAlertViewDelegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //ok pressed
        NSLog(@"delete Observation");
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        [persistenceManager deleteObservation:observation.observationId];
        [persistenceManager closeConnection];
        
        [observation.inventory.observations removeObjectAtIndex:currIndexPath.row];
        
        [observation setObservation:nil];
        
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        [tableView deselectRowAtIndexPath:currIndexPath animated:YES];
    }
}

#pragma mark
#pragma UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"areaObservationDelete", nil)
                                                                message:NSLocalizedString(@"areaObservationDeleteMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil)
                                                      otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
            [areaAlert show];
            break;
        }
        case 1:
        {
            NSLog(@"cancel delete Area");
            [tableView deselectRowAtIndexPath:currIndexPath animated:NO];
            break;
        }
    }
}

@end
