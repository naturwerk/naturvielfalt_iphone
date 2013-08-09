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
#import <QuartzCore/QuartzCore.h>

@interface CollectionInventoriesController ()

@end

@implementation CollectionInventoriesController
@synthesize table, inventories, noEntryFoundLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        doSubmit = NO;
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"areaSubmitInventory", nil);
    self.navigationItem.title = title;

    table.delegate = self;
    
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    // Reload the inventories
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadInventories) onTarget:self withObject:nil animated:YES];*/
    
    // Reload table
    [table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [self setNoEntryFoundLabel:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = NO;
    loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    loadingHUD.mode = MBProgressHUDModeCustomView;
    [self reloadInventories];
}

- (void) removeInventories
{
    [table setEditing:!table.editing animated:YES];
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
    
    if(table.editing) {
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    }
    
    [table reloadData];
    
    // If there aren't any inventories in the list. Stop the editing mode.
    if([inventories count] < 1) {
        table.editing = NO;
        table.hidden = YES;
        noEntryFoundLabel.hidden = NO;
    } else {
        table.hidden = NO;
        noEntryFoundLabel.hidden = YES;
    }
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
        
        [inventories removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([inventories count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        // Reload the observations from the database and refresh the TableView
        //[self reloadInventories];
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
        
        if (inventory.submitted && [inventory checkAllObservationsFromInventorySubmitted]) {
            checkboxInventoryCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxInventoryCell.submitted.hidden = NO;
            checkboxInventoryCell.submitted.text = NSLocalizedString(@"navSubmitted", nil);
            [checkboxInventoryCell.count setAlpha:0.4f];
            [checkboxInventoryCell.date setAlpha:0.4f];
            //Images are not implemented yet
            //[checkboxInventoryCell.image setAlpha:0.5f];
            checkboxInventoryCell.checkbox.hidden = YES;
            inventory.submitToServer = NO;
        } else {
            checkboxInventoryCell.contentView.backgroundColor = [UIColor clearColor];
            checkboxInventoryCell.submitted.hidden = YES;
            [checkboxInventoryCell.count setAlpha:1];
            [checkboxInventoryCell.date setAlpha:1];
            checkboxInventoryCell.checkbox.hidden = NO;
            inventory.submitToServer = YES;
        }
        
        // Set checkbox icon
        /*if(inventory.submitToServer) {
            checkboxInventoryCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxInventoryCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }*/
    }
    checkboxInventoryCell.layer.shouldRasterize = YES;
    checkboxInventoryCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
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
    [table reloadData];
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
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:YES];
    areasSubmitNewInventoryController = nil;
}
@end
