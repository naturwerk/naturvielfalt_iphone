//
//  AreasSubmitInventoryController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitInventoryController.h"
#import "AreasSubmitNewInventoryController.h"
#import "AreasSubmitInventoryNameController.h"
#import "AreasSubmitController.h"
#import "InventoryCell.h"


@interface AreasSubmitInventoryController ()

@end

@implementation AreasSubmitInventoryController
@synthesize area, dateLabel, areaLabel, autherLabel, inventoryLabel, areaImage, inventoriesTable;

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
    
    NSLog(@"load settings for save area view");
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"areaSubmitInventory", nil);
    self.navigationItem.title = title;
    
    // Table init
    inventoriesTable.delegate = self;
    
    [self prepareData];
    
    // Reload table
    [inventoriesTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (area.areaId) {
        [persistenceManager establishConnection];
        Area *tmpArea = [persistenceManager getArea:area.areaId];
        [persistenceManager closeConnection];
        
        if (!tmpArea) {
            NSLog(@"area was deleted, go back");
            [area setArea:nil];
            area = nil;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // copy locationpoints from old area object
            NSMutableArray *lps = [[NSMutableArray alloc] initWithArray:area.locationPoints];
            area = tmpArea;
            area.locationPoints = [[NSMutableArray alloc] initWithArray:lps];
            lps = nil;
        }
    }
    // Reload table
    [inventoriesTable reloadData];
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setAutherLabel:nil];
    [self setAreaLabel:nil];
    [self setAutherLabel:nil];
    [self setInventoryLabel:nil];
    [self setAreaImage:nil];
    [self setInventoriesTable:nil];
    [super viewDidUnload];
}

- (void) prepareData
{
    NSString *nowString;
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:area.date];
    
    dateLabel.text = nowString;
    areaLabel.text = area.name;
    autherLabel.text = area.author;
    inventoryLabel.text = NSLocalizedString(@"areaSubmitInventory", nil);
    areaImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:area]]];
    
}

- (void) newInventory:(id)sender {
    NSLog(@"new inventory pressed");
    // new INVENTORY
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                                            initWithNibName:@"AreasSubmitNewInventoryController"
                                                                            bundle:[NSBundle mainBundle]];
    
    // create new inventory if no inventory is choosen
    Inventory *inventory = [[Inventory alloc] getInventory];
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    NSString *username = @"";
    
    if([appSettings objectForKey:@"username"] != nil) {
        username = [appSettings stringForKey:@"username"];
    }
    inventory.author = username;
    inventory.area = area;
    
    areasSubmitNewInventoryController.area = area;
    areasSubmitNewInventoryController.inventory = inventory;
    
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [tmp addObject:areasSubmitNewInventoryController];
    self.navigationController.viewControllers = tmp;
    
    // NAME
    // Create the AreasSubmitNameController
    AreasSubmitInventoryNameController *areasSubmitInventoryNameController = [[AreasSubmitInventoryNameController alloc]
                                                                              initWithNibName:@"AreasSubmitInventoryNameController"
                                                                              bundle:[NSBundle mainBundle]];
    
    
    areasSubmitInventoryNameController.inventory = inventory;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitInventoryNameController animated:YES];
    areasSubmitInventoryNameController = nil;
    
    
    // Switch the View & Controller
    //[self.navigationController pushViewController:areasSubmitNewInventoryController animated:YES];
    areasSubmitNewInventoryController = nil;}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [area.inventories count];
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath inventories");
    
    InventoryCell *cell = [tw dequeueReusableCellWithIdentifier:@"InventoryCell"];
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InventoryCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (InventoryCell *)currentObject;
                break;
            }
        }
    }
    
    Inventory *inventory = [area.inventories objectAtIndex:indexPath.row];
    
    if (inventory != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:inventory.date];
        
        cell.author.text = inventory.author;
        cell.name.text = inventory.name;
        cell.date.text = nowString;
        cell.observationsCount.text = [NSString stringWithFormat:@"%i",inventory.observations.count];
        
        // Define the action on the button and the current row index as tag
        [cell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.name setTag:inventory.inventoryId];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        InventoryCell *cell = (InventoryCell *)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = cell.name;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        Inventory *inventory = [persistenceManager getInventory:label.tag];
        
        // If Yes, delete the observation and inventory with the persistence manager
        [persistenceManager deleteObservations:inventory.observations];
        [persistenceManager deleteInventory:label.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [area.inventories removeObjectAtIndex:indexPath.row];
        
        // refresh the TableView
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                                      initWithNibName:@"AreasSubmitNewInventoryController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Inventory *inventory = [area.inventories objectAtIndex:indexPath.row];
    
    // Set the current displayed organism
    areasSubmitNewInventoryController.area = area;
    areasSubmitNewInventoryController.inventory = inventory;
    areasSubmitNewInventoryController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:YES];
    areasSubmitNewInventoryController = nil;
}


@end
