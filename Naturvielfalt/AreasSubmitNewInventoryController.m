//
//  AreasSubmitNewInventoryController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import "AreasSubmitNewInventoryController.h"
#import "AreasSubmitInventoryNameController.h"
#import "AreasSubmitInventoryDescriptionController.h"
#import "AreasSubmitInventoryObservationController.h"
#import "ObservationsViewController.h"
#import "CustomCell.h"
#import "CustomAddCell.h"
#import "MBProgressHUD.h"

@interface AreasSubmitNewInventoryController ()

@end

@implementation AreasSubmitNewInventoryController
@synthesize area, inventory, tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load settings for save inventory view");
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:(!review) ? @"Sichern"
                                     : @"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveInventory)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Abbrechen"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(abortInventory)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set navigation bar title
    NSString *title = @"Inventar";
    self.navigationItem.title = title;
    
    // Table init
    tableView.delegate = self;
    
    [self prepareData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareData {
    
    // create new inventory if no inventory is choosen
    if (!inventory)inventory = [[Inventory alloc] init];
    
    if (!review) {
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in inventory data object
        inventory.date = now;
        
        inventory.author = area.author;
    }
    
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowString = [dateFormatter stringFromDate:inventory.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:@"Zeit", @"Erfasser", @"Gebietsname", @"Inventarname", @"Beschreibung", nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, inventory.author, area.name, inventory.name, inventory.description, nil];
}

- (void) saveInventory {
    NSLog(@"save inventory pressed");
    if (!persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
    }
    
    // Save inventory
    if(review) {
        [persistenceManager updateInventory:inventory];
    } else {
        inventory.inventoryId = [persistenceManager saveInventory:inventory];
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
    hud.labelText = @"Inventar gespeichert";
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveInventory)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.parentViewController animated:TRUE];
}

- (void) abortInventory {
    NSLog(@"Abort Inventory pressed");
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
}

- (void) newObservation {
    NSLog(@"new inventory pressed");
    // new INVENTORY
    ObservationsViewController *observationsViewController = [[ObservationsViewController alloc]
                                                              initWithNibName:@"ObservationsViewController"
                                                              bundle:[NSBundle mainBundle]];
    
    
    // Switch the View & Controller
    [self.navigationController pushViewController:observationsViewController animated:TRUE];
    observationsViewController = nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if (section == 0) {
        return [arrayKeys count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    CustomCell *customCell;
    CustomAddCell *customAddCell;
    
    if (indexPath.section == 0) {
        if(indexPath.row > 2) {
            // use CustomCell layout
            
            if(cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                
                for (id currentObject in topLevelObjects){
                    if ([currentObject isKindOfClass:[UITableViewCell class]]){
                        customCell =  (CustomCell *)currentObject;
                        break;
                    }
                }
                
                switch(indexPath.row) {
                    case 3:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (inventory.name.length > 10) ? @"..." : inventory.name;
                        customCell.image.image = nil;
                    }
                        break;
                        
                    case 4:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (inventory.description.length > 0) ? @"..." : @"";
                        customCell.image.image = nil;
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
            
            return cell;
        }
    } else {
        
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAddCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    customAddCell =  (CustomAddCell *)currentObject;
                    break;
                }
            }
            
            NSLog(@"section %i", indexPath.section);
            customAddCell.key.text = @"Beobachtungen";
            customAddCell.value.text = @"3";
            [customAddCell.addButton addTarget:self action:@selector(newObservation) forControlEvents:UIControlEventTouchUpInside];
            
            return customAddCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
        [self rowClicked:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [self rowClicked:indexPath];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    NSLog(@"index Path: %@", indexPath);
    AreasSubmitInventoryNameController *areasSubmitInventoryNameController;
    AreasSubmitInventoryDescriptionController *areasSubmitInventoryDescriptionController;
    AreasSubmitInventoryObservationController *areasSubmitInventoryObservationController;
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 3:
                // NAME
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitInventoryNameController = [[AreasSubmitInventoryNameController alloc]
                                             initWithNibName:@"AreasSubmitInventoryNameController"
                                             bundle:[NSBundle mainBundle]];
                
                
                areasSubmitInventoryNameController.inventory = inventory;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitInventoryNameController animated:TRUE];
                areasSubmitInventoryNameController = nil;
                
                break;
            case 4:
                // DESCRIPTION
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitInventoryDescriptionController = [[AreasSubmitInventoryDescriptionController alloc]
                                                    initWithNibName:@"AreasSubmitInventoryDescriptionController"
                                                    bundle:[NSBundle mainBundle]];
                
                areasSubmitInventoryDescriptionController.inventory = inventory;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitInventoryDescriptionController animated:TRUE];
                areasSubmitInventoryDescriptionController = nil;
                
                break;
        }
    } else {
        
        // OBSERVATION
        // Create the ObservationsOrganismSubmitMapController
        areasSubmitInventoryObservationController = [[AreasSubmitInventoryObservationController alloc]
                                          initWithNibName:@"AreasSubmitInventoryObservationController"
                                          bundle:[NSBundle mainBundle]];
        
        areasSubmitInventoryObservationController.inventory = inventory;
        areasSubmitInventoryObservationController.area = area;

        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitInventoryObservationController animated:TRUE];
        areasSubmitInventoryObservationController = nil;
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
