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
#import "ObservationsOrganismSubmitMapController.h"
#import "CameraViewController.h"
#import "ObservationsOrganismSubmitAmountController.h"
#import "ObservationsOrganismSubmitCommentController.h"
#import "MBProgressHUD.h"

@implementation ObservationsOrganismSubmitController
@synthesize nameDe, nameLat, organism, observation, tableView, arrayKeys, arrayValues, accuracyImage, locationManager, accuracyText, family, persistenceManager, review, observationChanged, comeFromOrganism;

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
    nameDe.text = [organism getNameDe];
    nameLat.text = (organism.organismGroupId == 1000) ? @"" : [organism getLatName];
    family.text = organism.family;
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:(!review) ? @"Sichern" 
                                                            : @"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveObservation)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button  
    UIBarButtonItem *chancelButton = [[UIBarButtonItem alloc] 
                                      initWithTitle:@"Abbrechen"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortObsersation)];
    self.navigationItem.leftBarButtonItem = chancelButton;
    
    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithString:@"Beobachtung"];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:observation.date];
      
    // Initialize keys/valu es
    arrayKeys = [[NSArray alloc] initWithObjects:@"Zeit", @"Erfasser", @"Anzahl", @"Bemerkung", @"Belegfotos", @"Genauigkeit", nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, observation.author, observation.amount, @">", nil];
}

- (void) saveObservation 
{
    persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    
    // Save observation
    if(review) {
        [persistenceManager updateObservation:observation];
    } else {
        observation.observationId = [persistenceManager saveObservation:observation];
    }
    
    // Close connection
    [persistenceManager closeConnection];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.parentViewController.view];
    [self.navigationController.parentViewController.view addSubview:hud];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.customView = image;
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    //hud.delegate = self;
    hud.labelText = @"Beobachtung Gespeichert";
    
    [hud show:YES];
    [hud hide:YES afterDelay:5];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Ändern"
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

- (void) abortObsersation
{
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
}

- (void)viewDidUnload
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayKeys count];
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
    static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        // Set up the cell...
        cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];        
        cell.detailTextLabel.text = [arrayValues objectAtIndex:indexPath.row];
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
        // Create the ObservationsOrganismSubmitCameraController
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
        organismSubmitMapController.review = review;
        
        
        // Switch the View & Controller
        [self.navigationController pushViewController:organismSubmitMapController animated:TRUE];
        organismSubmitMapController = nil;
    }
}

@end
