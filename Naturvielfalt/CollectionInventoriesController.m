//
//  CollectionInventoriesController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import "CollectionInventoriesController.h"
#import "CheckboxInventoryCell.h"
#import "Inventory.h"
#import "Reachability.h"
#import "AreasSubmitNewInventoryController.h"
#import "AreasSubmitController.h"

@interface CollectionInventoriesController ()

@end

@implementation CollectionInventoriesController
@synthesize tableView, inventories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        doSubmit = FALSE;
    }
    persistenceManager = [[PersistenceManager alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"areaSubmitInventory", nil);
    self.navigationItem.title = title;
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navSubmit", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(alertOnSendInventoriesDialog)];
    
    self.navigationItem.rightBarButtonItem = filterButton;

    tableView.delegate = self;
    
    // Reload the inventories
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    [self reloadInventories];
    
    // Reload table
    [tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    tableView.editing = FALSE;
    [self beginLoadingInventories];
}

- (void) removeInventories
{
    [tableView setEditing:!tableView.editing animated:YES];
}

- (void) reloadInventories {
    NSLog(@"reload inventories");
    
    // Reset inventories
    inventories = nil;
    
    [self beginLoadingInventories];
}

- (void) beginLoadingInventories {
    NSLog(@"begin loading inventories");
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadInventories) object:nil];
    [operationQueue addOperation:operation];
}

- (void) synchronousLoadInventories {
    NSLog(@"synchronousLoadInventories");
    // Establish a connection
    [persistenceManager establishConnection];
    
    // Get all inventories
    NSMutableArray *arrNewInventories = [persistenceManager getInventories];
    
    [persistenceManager closeConnection];
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingInventories:) withObject:arrNewInventories waitUntilDone:YES];
}

- (void)didFinishLoadingInventories:(NSMutableArray *)arrNewInventories
{
    if(inventories != nil){
        if([inventories count] != [arrNewInventories count]){
            inventories = arrNewInventories;
        }
    }
    else {
        inventories = arrNewInventories;
    }
    
    countInventories = (int *)self.inventories.count;
    
    if(tableView.editing) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    }
    
    [tableView reloadData];
    
    // If there aren't any inventories in the list. Stop the editing mode.
    if([inventories count] < 1) {
        tableView.editing = FALSE;
    }
}


//Check if there is an active WiFi connection
- (BOOL) connectedToWiFi{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = false;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = true;
	}
	
	return result;
}

//fires an alert if not connected to WiFi
- (void) alertOnSendInventoriesDialog{
    doSubmit = TRUE;
    if([self connectedToWiFi]){
        [self sendInventories];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertInvTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertInvDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(doSubmit){
        if (buttonIndex == 1){
            [self sendInventories];
        }
        doSubmit = FALSE;
    }
}

- (void) sendInventories {
    NSLog(@"send Inventories");
}

#pragma UITableViewDelegates methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [inventories count];
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxInventoryCell *cell = (CheckboxInventoryCell *)[tv cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        Inventory *inventory = [persistenceManager getInventory:button.tag];
        
        // If Yes, delete the observation and inventory with the persistence manager
        [persistenceManager deleteObservations:inventory.observations];
        [persistenceManager deleteInventory:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        // Reload the observations from the database and refresh the TableView
        [self reloadInventories];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CheckboxInventoryCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout
    CheckboxInventoryCell *checkboxInventoryCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxInventoryCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxInventoryCell =  (CheckboxInventoryCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxInventoryCell = (CheckboxInventoryCell *)cell;
    }
    
    Inventory *inventory = [inventories objectAtIndex:indexPath.row];
    
    if(inventory != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:inventory.date];
        
        
        checkboxInventoryCell.title.text = inventory.name;
        checkboxInventoryCell.date.text = nowString;
        checkboxInventoryCell.count.text = [NSString stringWithFormat:@"%i", inventory.observations.count];
        checkboxInventoryCell.subtitle.text = inventory.area.name;
        checkboxInventoryCell.areaMode.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:inventory.area]]];
        
        // Define the action on the button and the current row index as tag
        [checkboxInventoryCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxInventoryCell.checkbox setTag:inventory.inventoryId];
        
        // Define the action on the button and the current row index as tag
        [checkboxInventoryCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxInventoryCell.remove setTag:inventory.inventoryId];
        
        // Set checkbox icon
        if(inventory.submitToServer) {
            checkboxInventoryCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxInventoryCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }
    }
    
    return checkboxInventoryCell;
}

- (void) checkboxEvent:(UIButton *)sender {
    NSLog(@"checkboxEvent");
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Inventory *iv in inventories) {
        if(iv.inventoryId == [number longLongValue]) {
            iv.submitToServer = !iv.submitToServer;
        }
    }
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Create the ObservationsOrganismViewController
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                                      initWithNibName:@"AreasSubmitNewInventoryController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Inventory *inventory = [inventories objectAtIndex:indexPath.row];
    
    // Store the current observation object
    Inventory *inventoryShared = [[Inventory alloc] getInventory];
    [inventoryShared setInventory:inventory];
    
    NSLog(@"Observation in CollectionOverView: %@", [inventoryShared getInventory]);
    
    // Set the current displayed organism
    areasSubmitNewInventoryController.inventory = inventory;
    areasSubmitNewInventoryController.area = inventory.area;
    areasSubmitNewInventoryController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;
}
@end
