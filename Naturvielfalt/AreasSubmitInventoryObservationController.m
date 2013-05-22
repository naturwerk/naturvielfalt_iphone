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

@interface AreasSubmitInventoryObservationController ()

@end

@implementation AreasSubmitInventoryObservationController
@synthesize dateLabel, inventoryLabel, areaLabel, area, inventory, observationLabel,observationsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        
        [persistenceManager establishConnection];
        inventory = [persistenceManager getInventory:inventory.inventoryId];

        [persistenceManager closeConnection];
        
        if (!inventory) {
            NSLog(@"inventory was deleted, go back");
            [inventory setInventory:nil];
            inventory = nil;
            [self.navigationController popViewControllerAnimated:TRUE];
            return;
        }
    }
    
    if (area.areaId) {
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        
        [persistenceManager establishConnection];
        Area *tmpArea = [persistenceManager getArea:area.areaId];
        [persistenceManager closeConnection];
        
        if (!tmpArea) {
            NSLog(@"area was deleted, go back");
            [inventory setInventory:nil];
            inventory = nil;
            [area setArea:nil];
            area = nil;
            [self.navigationController popViewControllerAnimated:TRUE];
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
    // new INVENTORY
    ObservationsViewController *observationsViewController = [[ObservationsViewController alloc]
                                                                            initWithNibName:@"ObservationsViewController"
                                                                            bundle:[NSBundle mainBundle]];
    
    observationsViewController.inventory = inventory;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:observationsViewController animated:TRUE];
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
    NSLog(@"cellForRowAtIndexPath observations");
    
    static NSString *cellIdentifier = @"InventoryCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    ObservationCell *observationCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ObservationCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                observationCell =  (ObservationCell *)currentObject;
                break;
            }
        }
    } else {
        observationCell = (ObservationCell *)cell;
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
            observationCell.photo.image = final;
            NSLog(@"Image!: %@", [observation.organism getNameDe]);
        }
        else {
            observationCell.photo.image = [UIImage imageNamed:@"blank.png"];
        }
        
        observationCell.name.text = observation.organism.getNameDe;
        observationCell.latName.text = observation.organism.getLatName;
        observationCell.date.text = nowString;
        observationCell.count.text = [NSString stringWithFormat:@"%@",observation.amount];
        // Define the action on the button and the current row index as tag
        [observationCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [observationCell.name setTag:observation.observationId];
    }
    return observationCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ObservationCell *cell = (ObservationCell *)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = cell.name;
        
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:label.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [inventory.observations removeObjectAtIndex:indexPath.row];
        
        // refresh the TableView
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *observationsOrganismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                            initWithNibName:@"ObservationsOrganismSubmitController"
                                                                            bundle:[NSBundle mainBundle]];
    
    Observation *observation = [inventory.observations objectAtIndex:indexPath.row];
    
    // Set the current displayed organism
    observationsOrganismSubmitController.observation = observation;
    observationsOrganismSubmitController.inventory = inventory;
    observationsOrganismSubmitController.organism = observation.organism;
    observationsOrganismSubmitController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:observationsOrganismSubmitController animated:TRUE];
    observationsOrganismSubmitController = nil;
}

@end
