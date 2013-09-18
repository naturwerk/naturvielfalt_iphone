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
#import "NaturvielfaltAppDelegate.h"

@interface CollectionInventoriesController ()

@end

NaturvielfaltAppDelegate *app;
@implementation CollectionInventoriesController
@synthesize table, pager, persistenceManager, loadingHUD, noEntryFoundLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"areaSubmitInventory", nil);
    self.navigationItem.title = title;

    table.delegate = self;
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxInventoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxInventoryCell"];
    
    [self setupTableViewFooter];
    
    loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    loadingHUD.mode = MBProgressHUDModeCustomView;
    [pager fetchFirstPage];
    app.inventoriesChanged = NO;
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
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
    if(app.inventoriesChanged){
        [pager reset];
        table.editing = NO;
        loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
        loadingHUD.mode = MBProgressHUDModeCustomView;
        [pager fetchFirstPage];
        app.inventoriesChanged = NO;
    }
}

- (void) removeInventories
{
    [table setEditing:!table.editing animated:YES];
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        Inventory *inventory = [pager.results objectAtIndex:indexPath.row];
        
        // If Yes, delete the observation and inventory with the persistence manager
        [persistenceManager deleteObservations:inventory.observations];
        [persistenceManager deleteInventory:inventory.inventoryId];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [pager.results removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([pager.results count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
    
    //update tablefooter
    pager.total--;
    [self updateTableViewFooter];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CheckboxInventoryCell" forIndexPath:indexPath];
    
    // use CustomCell layout
    CheckboxInventoryCell *checkboxInventoryCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxInventoryCell" owner:self options:nil];
        
        checkboxInventoryCell =  (CheckboxInventoryCell *)topLevelObjects[0];

    } else {
        checkboxInventoryCell = (CheckboxInventoryCell *)cell;
    }
    
    Inventory *inventory = [pager.results objectAtIndex:indexPath.row];
    
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
    
    for(Inventory *iv in pager.results) {
        if(iv.inventoryId == [number longLongValue]) {
            iv.submitToServer = !iv.submitToServer;
        }
    }
    [table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Create the ObservationsOrganismViewController
    if(!areasSubmitNewInventoryController)
    areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                                      initWithNibName:@"AreasSubmitNewInventoryController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Inventory *inventory = [pager.results objectAtIndex:indexPath.row];
    
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
}
@end
