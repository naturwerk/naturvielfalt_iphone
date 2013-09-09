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
#import "CustomDateCell.h"
#import "ObservationsOrganismSubmitDateController.h"
#import "ObservationsOrganismSubmitMapController.h"
#import "ObservationsOrganismViewController.h"
#import "CameraViewController.h"
#import "ObservationsOrganismSubmitAmountController.h"
#import "ObservationsOrganismSubmitCommentController.h"
#import "ObservationOrganismSubmitOrganismGroupController.h"
#import "ObservationsViewController.h"
#import "MBProgressHUD.h"
#import "SwissCoordinates.h"

extern int UNKNOWN_ORGANISMGROUPID;
extern int UNKNOWN_ORGANISMID;

#define numOfRowInSectionNull     1
#define numOfRowInSectionOne      2
#define numOfRowInSectionTwo      5
#define numOfRowInSectionThree    1

#define numOfSections             4

@implementation ObservationsOrganismSubmitController
@synthesize nameDe, nameLat, organism, observation, tableView, accuracyImage, locationManager, accuracyText, family, persistenceManager, review, observationChanged, comeFromOrganism, dateFormatter, organismButton, organismDataView, organismGroup, firstLineOrganismButton, secondLineOrganismButton, organismView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated {
    if (observation.observationId) {
        organismDataView.hidden = YES;
        organismButton.hidden = NO;
        
        NSString *organismName;
        NSString *organismLatName;
        
        if (observation.organism.organismId != UNKNOWN_ORGANISMID) {
            organismName = [observation.organism getName];
            organismLatName = [observation.organism getLatName];
        } else {
            organismName = NSLocalizedString(@"unknownOrganism", nil);
            organismLatName = NSLocalizedString(@"toBeDetermined", nil);
        }
        firstLineOrganismButton.text = organismName;
        secondLineOrganismButton.text = organismLatName;
        
        /*[organismButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [organismButton.titleLabel setTextAlignment:UITextAlignmentCenter];
        [organismButton setTitle:buttonTitle forState:UIControlStateNormal];*/
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [observation setObservation:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
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
    
    nameDe.text = [organism getName];
    nameLat.text = (organism.organismId == UNKNOWN_ORGANISMID) ? NSLocalizedString(@"toBeDetermined", nil) : [organism getLatName];
    family.text = organism.family;
    
    NSString *organismName;
    NSString *organismLatName;
    if (observation.organism.organismId != UNKNOWN_ORGANISMID) {
        organismName = [observation.organism getName];
        organismLatName = [observation.organism getLatName];
    } else {
        organismName = NSLocalizedString(@"unknownOrganism", nil);
        organismLatName = NSLocalizedString(@"toBeDetermined", nil);
    }
    
    /*organismButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    organismButton.frame = CGRectMake(60, 5, 200, 55);
    organismButton.hidden = YES;
    [organismView addSubview:organismButton];*/

    firstLineOrganismButton = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
    [firstLineOrganismButton setTextAlignment:UITextAlignmentCenter];
    //firstLineOrganismButton.text = organismName;
    firstLineOrganismButton.backgroundColor = [UIColor clearColor];
    firstLineOrganismButton.font = [UIFont boldSystemFontOfSize:15];
    [organismButton addSubview:firstLineOrganismButton];
    
    secondLineOrganismButton = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 180, 20)];
    [secondLineOrganismButton setTextAlignment:UITextAlignmentCenter];
    //secondLineOrganismButton.text = organismLatName;
    secondLineOrganismButton.backgroundColor = [UIColor clearColor];
    secondLineOrganismButton.textColor = [UIColor grayColor];
    secondLineOrganismButton.font = [UIFont italicSystemFontOfSize:13];
    [organismButton addSubview:secondLineOrganismButton];
    
    [organismButton addTarget:self action:@selector(chooseOrganism:) forControlEvents:UIControlEventTouchUpInside];
    
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
                                      action: @selector(abortObsersation)];
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
    }else {
        [self updateAccuracyIcon: (int)observation.accuracy];
        [tableView reloadData];
    }
    //observationChanged = true;
}

- (void) prepareData 
{
    // Create new observation object, will late be used as data transfer object
    if(!observation) observation = [[[Observation alloc] init] getObservation];
    
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
    }
     
    // Get formatted date string
    nowString = [dateFormatter stringFromDate:observation.date];
    
    // Initialize keys/valu es
    arrayKeysSectionNull = [[NSArray alloc] initWithObjects:NSLocalizedString(@"observationSpecies", nil), nil];
    
    arrayKeysSectionOne = [[NSArray alloc] initWithObjects:NSLocalizedString(@"observationTime", nil), NSLocalizedString(@"observationAuthor", nil), nil];
    
    arrayKeysSectionTwo = [[NSArray alloc] initWithObjects:NSLocalizedString(@"observationCtn", nil), NSLocalizedString(@"observationImg", nil), NSLocalizedString(@"observationDescr", nil), NSLocalizedString(@"observationAcc", nil), NSLocalizedString(@"observationCoordinates", nil), nil];
}

- (void) saveObservation
{
    [persistenceManager establishConnection];
    
    // Save observation
    if(review) {
        [persistenceManager deleteObservationImagesFromObservation:observation.observationId];
        [persistenceManager updateObservation:observation];
    } else {
        observation.observationId = [persistenceManager saveObservation:observation];
        for (ObservationImage *oImg in observation.pictures) {
            oImg.observationId = observation.observationId;
            oImg.observationImageId = [persistenceManager saveObservationImage:oImg];
        }
    }
    
    // Close connection
    [persistenceManager closeConnection];
    [observation setObservation:nil];
    
    if (!review) {
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
    }
    
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
    
    if(comeFromOrganism){
        //TODO go back to the artgroup
    }
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.parentViewController animated:TRUE];
}

- (IBAction)chooseOrganism:(id)sender {
    NSLog(@"chooseOrganism %@", organismButton.titleLabel.text);
    
    if (observation.organismGroup.organismGroupId != UNKNOWN_ORGANISMGROUPID) {
        // Create the ObservationsOrganismViewController
        ObservationsOrganismViewController *organismController = [[ObservationsOrganismViewController alloc]
                                                                  initWithNibName:@"ObservationsOrganismViewController"
                                                                  bundle:[NSBundle mainBundle]];
        
        // set the organismGroupId so it know which inventory is selected
        organismController.organismGroupId = observation.organismGroup.organismGroupId;
        organismController.organismGroupName = observation.organismGroup.name;
        organismController.organismGroup = observation.organismGroup;
        organismController.observation = observation;
        
        // Switch the View & Controller
        // (Also load all the organism from the organism group in the ViewDidLoad from ObsvervationsOrganismViewController)
        [self.navigationController pushViewController:organismController animated:TRUE];

        organismController = nil;
    } else {
        ObservationsViewController *observationsViewController = [[ObservationsViewController alloc] initWithNibName:@"ObservationsViewController" bundle:[NSBundle mainBundle]];
        observationsViewController.observation = observation;
        [self.navigationController pushViewController:observationsViewController animated:YES];
    }
}

- (void) abortObsersation
{
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
}

- (void)viewDidUnload
{
    [self setOrganismButton:nil];
    [self setOrganismDataView:nil];
    [self setOrganismView:nil];
    [self setOrganismButton:nil];
    [super viewDidUnload];

    if(locationManager){
        [locationManager stopUpdatingLocation];
       
         locationManager = nil;
    }
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

- (NSString *) getSwissCoordinates:(CLLocationCoordinate2D)theCoordinate
{
    // Calculate swiss coordinates
    SwissCoordinates *swissCoordinates = [[SwissCoordinates alloc] init];
    NSMutableArray *arrayCoordinates = [swissCoordinates calculate:theCoordinate.longitude latitude:theCoordinate.latitude];
    
    NSString *resString = [NSString	stringWithFormat:@"CH03 %.0f / %.0f", [[arrayCoordinates objectAtIndex:0] doubleValue], [[arrayCoordinates objectAtIndex:1] doubleValue]];
    
    return resString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (observation.observationId) {
        return numOfSections;
    }
    return numOfSections - 1;}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return numOfRowInSectionNull; break;
        case 1: return numOfRowInSectionOne; break;
        case 2: return numOfRowInSectionTwo; break;
        case 3: return numOfRowInSectionThree; break;
    }
    return 1;
}

#pragma mark
#pragma mark CLLocationManagerDelegate Methods
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if(!observation.locationLocked && !review) {
        if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] > 8)
            NSLog(@"LocationManager timeout");
        else if ((newLocation.horizontalAccuracy <= manager.desiredAccuracy) && (newLocation.verticalAccuracy <= manager.desiredAccuracy))
            NSLog(@"Desired accuracy reached!");
        
        
        // Update the Accuracy Image
        [self updateAccuracyIcon: (int)newLocation.horizontalAccuracy];

        // update the observation data object
        observation.location = newLocation;
        observation.accuracy = (int)newLocation.horizontalAccuracy;
        NSLog( @"set new location from locationmanager; accuracy: %d", observation.accuracy);
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
    
    // use CustomCell layout
    CustomCell *customCell;
    CustomDateCell *customDateCell;
    
    NSArray *topLevelObjects;
    NSLog(@"section: %i and row %i", indexPath.section, indexPath.row);
    
    switch (indexPath.section) {
            // Species
        case 0:
            if(cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                customCell =  (CustomCell *)topLevelObjects[0];
                
                if (observation.observationId) {
                    customCell.key.text = [arrayKeysSectionNull objectAtIndex:indexPath.row];
                    customCell.value.text = observation.organism.organismGroupName;
                    customCell.image.image = nil;
                    return customCell;
                } else {
                    // Use normal cell layout
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    }
                    
                    // Set up the cell...
                    cell.textLabel.text = [arrayKeysSectionNull objectAtIndex:indexPath.row];
                    NSLog(@"%i", indexPath.row);
                    //cell.detailTextLabel.text = [arrayValuesSectionOne objectAtIndex:indexPath.row];
                    cell.detailTextLabel.text = observation.organism.organismGroupName;
                    cell.editing = NO;
                    cell.userInteractionEnabled = NO;
                    
                    return cell;
                }
            }
            break;
            // Date and Observator
        case 1:
            switch (indexPath.row) {
                case 0: //DATE
                    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomDateCell" owner:self options:nil];
                    customDateCell =  (CustomDateCell *)topLevelObjects[0];
                    
                    customDateCell.key.text = [arrayKeysSectionOne objectAtIndex:indexPath.row];
                    customDateCell.value.text = [dateFormatter stringFromDate:observation.date];
                    return customDateCell;
                    break;
                    
                case 1: //OBSERVER
                    // Use normal cell layout
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    }
                    
                    // Set up the cell...
                    cell.textLabel.text = [arrayKeysSectionOne objectAtIndex:indexPath.row];
                    //cell.detailTextLabel.text = [arrayValuesSectionOne objectAtIndex:indexPath.row];
                    cell.detailTextLabel.text = (observation.author.length > 0) ? observation.author : @"-";
                    cell.userInteractionEnabled = NO;
                    return cell;
                    break;
            }
            break;
            // Amount, Comment, Photograph and Accuracy
        case 2:
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
            customCell =  (CustomCell *)topLevelObjects[0];
            
            switch (indexPath.row) {
                case 0: // AMOUNT
                {
                    customCell.key.text = [arrayKeysSectionTwo objectAtIndex:indexPath.row];
                    customCell.value.text = observation.amount;
                    customCell.image.image = nil;
                }
                    break;
                    
                case 1: // PHOTO
                {
                    customCell.key.text = [arrayKeysSectionTwo objectAtIndex:indexPath.row];
                    
                    NSString *picCount = [[NSString alloc] initWithFormat:@"%d", observation.pictures.count];
                    
                    customCell.value.text = picCount;
                    customCell.image.image = nil;
                }
                    break;
                    
                case 2: // COMMENT
                {
                    customCell.key.text = [arrayKeysSectionTwo objectAtIndex:indexPath.row];
                    customCell.value.text = (observation.comment.length > 0) ? @"..." : @"-";
                    customCell.image.image = nil;
                    
                }
                    break;
                    
                case 3: // ACCURACY
                {
                    [self updateAccuracyIcon:observation.accuracy];
                    
                    customCell.key.text = [arrayKeysSectionTwo objectAtIndex:indexPath.row];
                    customCell.image.image = accuracyImage; // --------->
                    customCell.value.text = accuracyText;
                }
                    break;
                    
                case 4: // Swiss Coordinates
                {
                    // Use normal cell layout
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    }
                    
                    // Set up the cell...
                    cell.textLabel.text = [arrayKeysSectionTwo objectAtIndex:indexPath.row];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
                    NSString *swissCoordinates = [self getSwissCoordinates:observation.location.coordinate];
                    cell.detailTextLabel.text = swissCoordinates.length > 0 ? swissCoordinates : @"-";
                    cell.userInteractionEnabled = NO;
                    return cell;
                }
                    break;
            }
            return customCell;
            break;
            
            // Delete Button
        case 3: // DELETE
            if(cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DeleteCell" owner:self options:nil];
                deleteCell =  (DeleteCell *)topLevelObjects[0];

                deleteCell.deleteLabel.text = NSLocalizedString(@"areaObservationDelete", nil);
                return deleteCell;
            }
            break;
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        CAGradientLayer *gradientLayerUnselected;
        UIColor *lighterColorUnselected = [UIColor colorWithRed:225/255.0 green:132/255.0 blue:133/255.0 alpha:1];
        UIColor *darkerColorUnselected = [UIColor colorWithRed:175/255.0 green:10/255.0 blue:12/255.0 alpha:1];
        
        gradientLayerUnselected = [CAGradientLayer layer];
        gradientLayerUnselected.cornerRadius = 8;
        gradientLayerUnselected.frame = CGRectMake(10, 0, 300, 44);
        gradientLayerUnselected.colors = [NSArray arrayWithObjects:(id)[lighterColorUnselected CGColor], (id)[darkerColorUnselected CGColor], nil];
        [cell.layer insertSublayer:gradientLayerUnselected atIndex:0];

    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    
    currIndexPath = indexPath;
    
    ObservationOrganismSubmitOrganismGroupController *organismSubmitOrganismGroupController;
    ObservationsOrganismSubmitDateController *organismSubmitDateController;
    ObservationsOrganismSubmitAmountController *organismSubmitAmountController;
    ObservationsOrganismSubmitCommentController *organismSubmitCommentController;
    CameraViewController *organismSubmitCameraController;
    ObservationsOrganismSubmitMapController *organismSubmitMapController;
    
    switch (indexPath.section) {
        case 0: {
            // ORGANISM
            // Create the ObservationOrganismSubmitOrganismGroupController
            organismSubmitOrganismGroupController = [[ObservationOrganismSubmitOrganismGroupController alloc] initWithNibName:@"ObservationOrganismSubmitOrganismGroupController" bundle:[NSBundle mainBundle]];
            
            organismSubmitOrganismGroupController.observation = observation;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitOrganismGroupController animated:TRUE];
            organismSubmitOrganismGroupController = nil;
        }
            break;
            
        case 1: {
            // DATE
            // Create the ObservationsOrganismSubmitDateController
            organismSubmitDateController = [[ObservationsOrganismSubmitDateController alloc] initWithNibName:@"ObservationsOrganismSubmitDateController" bundle:[NSBundle mainBundle]];
            
            organismSubmitDateController.observation = observation;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitDateController animated:TRUE];
            organismSubmitDateController = nil;

        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {// Amount
                    // AMOUNT
                    // Create the ObservationsOrganismSubmitCameraController
                    organismSubmitAmountController = [[ObservationsOrganismSubmitAmountController alloc]
                                                                                                  initWithNibName:@"ObservationsOrganismSubmitAmountController"
                                                                                                  bundle:[NSBundle mainBundle]];
                    
                    
                    organismSubmitAmountController.observation = observation;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:organismSubmitAmountController animated:TRUE];
                    organismSubmitAmountController = nil;
                }
                    break;
                    
                case 1: {// Photograph
                    // CAMERA
                    // Create the ObservationsOrganismSubmitCameraController
                    organismSubmitCameraController = [[CameraViewController alloc]
                                                      initWithNibName:@"CameraViewController"
                                                      bundle:[NSBundle mainBundle]];
                    
                    
                    organismSubmitCameraController.observation = observation;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:organismSubmitCameraController animated:TRUE];
                    organismSubmitCameraController = nil;
                  
                }
                    break;
                
                case 2: {// Comment
                    // COMMENT
                    // Create the ObservationsOrganismSubmitCameraController
                    organismSubmitCommentController = [[ObservationsOrganismSubmitCommentController alloc]
                                                       initWithNibName:@"ObservationsOrganismSubmitCommentController"
                                                       bundle:[NSBundle mainBundle]];
                    
                    organismSubmitCommentController.observation = observation;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:organismSubmitCommentController animated:TRUE];
                    organismSubmitCommentController = nil;

                }
                    break;
                
                case 3: {// Accuracy
                    // MAP
                    // Create the ObservationsOrganismSubmitMapController
                    organismSubmitMapController = [[ObservationsOrganismSubmitMapController alloc]
                                                                                            initWithNibName:@"ObservationsOrganismSubmitMapController"
                                                                                            bundle:[NSBundle mainBundle]];
                    
                    organismSubmitMapController.observation = observation;
                    organismSubmitMapController.review = review;
                    
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:organismSubmitMapController animated:TRUE];
                    organismSubmitMapController = nil;
                }
                    break;
            }
        }
            break;
        case 3: {
            if (!deleteObservationSheet) {
                deleteObservationSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:NSLocalizedString(@"areaObservationDelete", nil) otherButtonTitles: nil];
                
                deleteObservationSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            }
            [deleteObservationSheet showFromTabBar:self.tabBarController.tabBar];

        }
            break;
    }
}

#pragma mark
#pragma UIAlertViewDelegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //ok pressed
        NSLog(@"delete Observation");
        [persistenceManager establishConnection];
        [persistenceManager deleteObservation:observation.observationId];
        [persistenceManager closeConnection];
        
        [observation setObservation:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
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
