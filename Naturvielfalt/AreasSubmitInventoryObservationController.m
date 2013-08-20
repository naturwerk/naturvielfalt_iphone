//
//  AreasSubmitInvetoryObservationController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import "AreasSubmitInventoryObservationController.h"
#import "ObservationsOrganismSubmitController.h"
#import "ObservationsViewController.h"
#import "ObservationCell.h"
#import "Observation.h"

extern int UNKNOWN_ORGANISMID;

@implementation AreasSubmitInventoryObservationController
@synthesize dateLabel, inventoryLabel, areaLabel, area, inventory, observationLabel,observationsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load settings for save observation view");
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"areaSubmitObservations", nil);
    self.navigationItem.title = title;
    
    // Table init
    observationsTableView.delegate = self;
    
    [self prepareData];
    
    // Reload table
    [observationsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    if (inventory.inventoryId) {
        [persistenceManager establishConnection];
        inventory = [persistenceManager getInventory:inventory.inventoryId];
        [persistenceManager closeConnection];
        
        if (!inventory) {
            NSLog(@"inventory was deleted, go back");
            [inventory setInventory:nil];
            inventory = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    if (area.areaId) {
        [persistenceManager establishConnection];
        Area *tmpArea = [persistenceManager getArea:area.areaId];
        [persistenceManager closeConnection];
        
        if (!tmpArea) {
            NSLog(@"area was deleted, go back");
            [inventory setInventory:nil];
            inventory = nil;
            [area setArea:nil];
            area = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        } else {
            // copy locationpoints from old area object
            NSMutableArray *lps = [[NSMutableArray alloc] initWithArray:area.locationPoints];
            area = tmpArea;
            area.locationPoints = [[NSMutableArray alloc] initWithArray:lps];
            inventory.area = area;
            lps = nil;
        }
    }
    [self prepareData];
    
    // Reload table
    [observationsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setInventoryLabel:nil];
    [self setAreaLabel:nil];
    [self setObservationsTableView:nil];
    [self setObservationLabel:nil];
    [super viewDidUnload];
}

- (void) prepareData {
    
    
    if (inventory) {
        NSLog(@"not empty");
    }
    NSString *nowString;
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:inventory.date];
    
    dateLabel.text = nowString;    
    inventoryLabel.text = inventory.name;
    areaLabel.text = area.name;
    observationLabel.text = NSLocalizedString(@"areaSubmitObservations", nil);
}

- (IBAction)newObservation:(id)sender {
    NSLog(@"new inventory pressed");
    // new Observation
    ObservationsViewController *observationsViewController = [[ObservationsViewController alloc]
                                                                            initWithNibName:@"ObservationsViewController"
                                                                            bundle:[NSBundle mainBundle]];
    
    observationsViewController.inventory = inventory;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:observationsViewController animated:YES];
    observationsViewController = nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [inventory.observations count];
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ObservationCell *cell = [tw dequeueReusableCellWithIdentifier:@"ObservationCell"];
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ObservationCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (ObservationCell *)currentObject;
                break;
            }
        }
    }
    
    Observation *observation = [inventory.observations objectAtIndex:indexPath.row];
    
    if (observation != nil) {
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
            cell.photo.image = final;
            NSLog(@"Image!: %@", [observation.organism getName]);
        }
        else {
            cell.photo.image = [UIImage imageNamed:@"blank.png"];
        }
        
        if (observation.organism.organismId == UNKNOWN_ORGANISMID) {
            //checkboxCell.name.text = NSLocalizedString(@"unknownOrganism", nil);
            //checkboxCell.latName.text = NSLocalizedString(@"toBeDetermined", nil);
            cell.name.textColor = [UIColor grayColor];
            cell.latName.textColor = [UIColor grayColor];
        } else {
            cell.name.textColor = [UIColor blackColor];
            cell.latName.textColor = [UIColor blackColor];
        }

        cell.name.text = [observation.organism getName];
        cell.latName.text = observation.organism.getLatName;
        cell.date.text = nowString;
        cell.count.text = [NSString stringWithFormat:@"%@",observation.amount];
        // Define the action on the button and the current row index as tag
        [cell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.name setTag:observation.observationId];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ObservationCell *cell = (ObservationCell *)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = cell.name;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:label.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [inventory.observations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // refresh the TableView
        //[tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                            initWithNibName:@"ObservationsOrganismSubmitController"
                                                                            bundle:[NSBundle mainBundle]];
    
    Observation *observation = [inventory.observations objectAtIndex:indexPath.row];
    //[observation setObservation:observation];
    
    // Set the current displayed organism
    organismSubmitController.observation = observation;
    organismSubmitController.inventory = inventory;
    organismSubmitController.organism = observation.organism;
    organismSubmitController.review = YES;
    organismSubmitController.organismGroup = observation.organismGroup;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:YES];
    organismSubmitController = nil;
}

@end
