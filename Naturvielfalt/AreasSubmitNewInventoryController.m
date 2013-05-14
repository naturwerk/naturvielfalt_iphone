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
#import "DeleteCell.h"
#import "CustomAddCell.h"
#import "MBProgressHUD.h"

@interface AreasSubmitNewInventoryController ()

@end

@implementation AreasSubmitNewInventoryController
@synthesize area, inventory, tableView, review, inventoryName;

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

- (void) viewDidAppear:(BOOL)animated {
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
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load settings for save inventory view");
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:(!review) ? NSLocalizedString(@"navSave", nil)
                                     : NSLocalizedString(@"navChange", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveInventory)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navCancel", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(abortInventory)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"areaSubmitNewInventory", nil);
    self.navigationItem.title = title;
    
    // Table init
    tableView.delegate = self;
    
    [self prepareData];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setInventoryName:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareData {
    
    // create new inventory if no inventory is choosen
    if (!inventory) {
        inventory = [[Inventory alloc] getInventory];
    }
    
    if (!review) {
        
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        NSString *username = @"";
        
        if([appSettings objectForKey:@"username"] != nil) {
            username = [appSettings stringForKey:@"username"];
        }
        
        inventory.author = username;
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in inventory data object
        inventory.date = now;
        
        inventory.author = area.author;
    }
    
    if ([inventory.name compare:@""] == 0) {
        inventoryName.text = NSLocalizedString(@"areaInventoryEmptyTitle", nil);
    } else {
        inventoryName.text = inventory.name;
    }
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowString = [dateFormatter stringFromDate:inventory.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:NSLocalizedString(@"areaSubmitTime", nil), NSLocalizedString(@"areaSubmitAuthor", nil), NSLocalizedString(@"areaSubmitName", nil), NSLocalizedString(@"areaSubmitInventoryName", nil), NSLocalizedString(@"areaSubmitDescr", nil), nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, inventory.author, area.name, inventory.name, inventory.description, nil];
}

- (void) saveInventory {
    NSLog(@"save inventory pressed");
    
    if ([inventory.name compare:@""] == 0) {
        UIAlertView *inventoryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageInventoryTitle", nil)
                                                            message:NSLocalizedString(@"alertMessageInventoryName", nil) delegate:self cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [inventoryAlert show];
        return;
    }
    
    inventory.area = area;
    // No duplicates, so remove if contains
    [area.inventories removeObject:inventory];
    [area.inventories addObject:inventory];
    
    if (!persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    
    [persistenceManager establishConnection];
    
    // Save inventory and update area
    if(review) {
        if (area.areaId) {
            // update area
            [persistenceManager updateArea:area];
            if (inventory.inventoryId) {
                // update inventory
                [persistenceManager updateInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    if (observation.observationId) {
                        // update observation
                        [persistenceManager updateObservation:observation];
                    } else {
                        // persist observation
                        observation.inventory = inventory;
                        observation.observationId = [persistenceManager saveObservation:observation];
                    }
                }
            } else {
                // persist inventory and observations
                inventory.area = area;
                inventory.inventoryId = [persistenceManager saveInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    observation.inventory = inventory;
                    observation.observationId = [persistenceManager saveObservation:observation];
                }
            }
        } else {
            // persist area, inventories and observations
            area.areaId = [persistenceManager saveArea:area];
            [persistenceManager saveLocationPoints:area.locationPoints areaId:area.areaId];
            for (Inventory *iv in area.inventories) {
                iv.area = area;
                iv.inventoryId = [persistenceManager saveInventory:iv];
                for (Observation *observation in iv.observations) {
                    observation.inventory = iv;
                    observation.observationId = [persistenceManager saveObservation:observation];
                }
            }
        }
    } else {
        if (area.areaId) {
            // update area
            [persistenceManager updateArea:area];
            if (inventory.inventoryId) {
                // update inventory
                [persistenceManager updateInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    if (observation.observationId) {
                        // update observation
                        [persistenceManager updateObservation:observation];
                    } else {
                        // persist observation
                        [persistenceManager saveObservation:observation];
                    }
                }
            } else {
                // persist inventory and observations
                inventory.area = area;
                inventory.inventoryId = [persistenceManager saveInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    observation.inventory = inventory;
                    observation.observationId = [persistenceManager saveObservation:observation];
                }
            }
        } else {
            // persist area, inventories and observations
            area.areaId = [persistenceManager saveArea:area];
            [persistenceManager saveLocationPoints:area.locationPoints areaId:area.areaId];
            for (Inventory *iv in area.inventories) {
                iv.area = area;
                iv.inventoryId = [persistenceManager saveInventory:inventory];
                for (Observation *observation in iv.observations) {
                    observation.inventory = iv;
                    observation.observationId = [persistenceManager saveObservation:observation];
                }
            }
        }
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
    hud.labelText = NSLocalizedString(@"areaInventoryHudSuccess", nil);
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
    // Set review flag
    review = true;
    
    [inventory setInventory:nil];
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navChange", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveInventory)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];

    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) abortInventory {
    NSLog(@"Abort Inventory pressed");
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) newObservation {
    NSLog(@"new observation pressed");
    
    if ([inventory.name compare:@""] == 0) {
        UIAlertView *inventoryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageInventoryTitle", nil)
                                                                 message:NSLocalizedString(@"alertMessageInventoryName", nil) delegate:self cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [inventoryAlert show];
        return;
    }
    
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
    NSLog(@"numberOfSectionsInTableView");
    if (inventory.inventoryId) {
        return 3;
    }
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
    DeleteCell *deleteCell;
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
    } else if (indexPath.section == 1) {
        
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAddCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    customAddCell =  (CustomAddCell *)currentObject;
                    break;
                }
            }
            
            NSLog(@"section %i", indexPath.section);
            customAddCell.key.text = NSLocalizedString(@"areaSubmitObservations", nil);
            customAddCell.value.text = [NSString stringWithFormat:@"%i", inventory.observations.count];;
            [customAddCell.addButton addTarget:self action:@selector(newObservation) forControlEvents:UIControlEventTouchUpInside];
            
            return customAddCell;
        }
    } else {
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DeleteCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    deleteCell =  (DeleteCell *)currentObject;
                    break;
                }
            }
            deleteCell.deleteLabel.text = NSLocalizedString(@"areaInventoryDelete", nil);
            return deleteCell;
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
    currIndexPath = indexPath;
    
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
    } else if (indexPath.section == 1) {
        
        if ([inventory.name compare:@""] == 0) {
            UIAlertView *inventoryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageInventoryTitle", nil)
                                                                     message:NSLocalizedString(@"alertMessageInventoryName", nil) delegate:self cancelButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
            [inventoryAlert show];
            return;
        }
        
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
    } else {
        if (!deleteInventorySheet) {
            deleteInventorySheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:NSLocalizedString(@"areaInventoryDelete", nil) otherButtonTitles: nil];
            
            deleteInventorySheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        [deleteInventorySheet showFromTabBar:self.tabBarController.tabBar];
    }
}

#pragma mark
#pragma UIAlertViewDelegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //ok pressed
        NSLog(@"delete Inventory");
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        [persistenceManager deleteObservations:inventory.observations];
        [persistenceManager deleteInventory:inventory.inventoryId];
        [persistenceManager closeConnection];
        
        [area.inventories removeObjectAtIndex:currIndexPath.row];
        
        [inventory setInventory:nil];
        
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
            UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"areaInventoryDelete", nil)
                                                                message:NSLocalizedString(@"areaInventoryDeleteMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil)
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
