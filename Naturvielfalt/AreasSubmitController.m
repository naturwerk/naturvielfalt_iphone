//
//  AreasSubmitMapController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.04.13.
//  Copyright (c) 2013 Naturwerk. All rights reserved.
//

#import "AreasSubmitController.h"
#import "AreasSubmitNameController.h"
#import "AreasSubmitDescriptionController.h"
#import "AreasSubmitInventoryController.h"
#import "AreasSubmitNewInventoryController.h"
#import "AreasSubmitDateController.h"
#import "AreasSubmitInventoryNameController.h"
#import "AreasViewController.h"
#import "CameraViewController.h"
#import "CustomCell.h"
#import "CustomDateCell.h"
#import "MBProgressHUD.h"
#import "CustomAddCell.h"
#import "CustomAreaCell.h"
#import "DeleteCell.h"

@interface AreasSubmitController ()

@end

@implementation AreasSubmitController
@synthesize areaChanged, area, tableView, drawMode, customAnnotation, review, areaName;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"load settings for save area view");
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"navSave", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button  
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                      initWithTitle:NSLocalizedString(@"navCancel", nil)
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortArea)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"areaSubmitTitle", nil);
    self.navigationItem.title = title;
    
    // Table init
    tableView.delegate = self;
    
    [self prepareData];
}

- (void) viewDidDisappear:(BOOL)animated {
    [area setArea:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareData 
{
    
    NSString *nowString;
    
    if(!review) {
        
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        NSString *username = @"";
        
        if([appSettings objectForKey:@"username"] != nil) {
            username = [appSettings stringForKey:@"username"];
        }
        
        area.author = username;
        
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in area data object
        area.date = now;
    }
    
    // Get formatted date string
    nowString = [dateFormatter stringFromDate:area.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:NSLocalizedString(@"areaSubmitTime", nil), NSLocalizedString(@"areaSubmitAuthor", nil), NSLocalizedString(@"areaSubmitName", nil), NSLocalizedString(@"areaSubmitDescr", nil),  NSLocalizedString(@"areaSubmitImages", nil), nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, area.author, area.name, area.description, @">", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (area.areaId) {
        [persistenceManager establishConnection];
        persistedArea = [persistenceManager getArea:area.areaId];
        [persistenceManager closeConnection];
    }
    if ([area.name compare:@""] == 0) {
        areaName.text = NSLocalizedString(@"areaEmptyTitle", nil);
    } else {
        areaName.text = area.name;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (area.areaId) {
        if (!persistedArea) {
            NSLog(@"area was deleted, go back to map");
            [area setArea:nil];
            area = nil;
            [self.navigationController popViewControllerAnimated:TRUE];
            return;
        } else {
            // copy locationpoints from old area object
            NSMutableArray *lps = [[NSMutableArray alloc] initWithArray:area.locationPoints];
            area = persistedArea;
            area.locationPoints = [[NSMutableArray alloc] initWithArray:lps];
            lps = nil;
        }
    }
    
    [tableView reloadData];
    
    if (area.persisted) {
        // Set top navigation bar button
        UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                         initWithTitle:NSLocalizedString(@"navChange", nil)
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action: @selector(saveArea)];
        self.navigationItem.rightBarButtonItem = submitButton;
    }

    
    if (!review) {
        // NAME
        // Create the AreasSubmitNameController
        /*AreasSubmitNameController *areasSubmitNameController = [[AreasSubmitNameController alloc]
                                                                initWithNibName:@"AreasSubmitNameController"
                                                                bundle:[NSBundle mainBundle]];
        
        
        areasSubmitNameController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitNameController animated:TRUE];
        areasSubmitNameController = nil;*/
        
        review = YES;
    }
}


- (void)viewDidUnload {
    [self setAreaName:nil];
    [super viewDidUnload];
}

- (void) saveArea
{
    if ([area.name compare:@""] == 0) {
        UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageAreaNameTitle", nil)
                                                            message:NSLocalizedString(@"alertMessageAreaName", nil) delegate:self cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [areaAlert show];
        return;
    }

    area.submitted = NO;
    [AreasSubmitController persistArea:area];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.parentViewController.view];
    [self.navigationController.parentViewController.view addSubview:hud];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.customView = image;
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    //hud.delegate = self;
    hud.labelText = NSLocalizedString(@"areaSubmitHudSuccess", nil);
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navSave", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];;


    if (!areasViewController) {
        areasViewController = [[AreasViewController alloc]
                               initWithNibName:@"AreasViewController"
                               bundle:[NSBundle mainBundle] area:area];
    } else {
        areasViewController.area = area;
    }

    [self.navigationController popViewControllerAnimated:TRUE];
}

+ (void) persistArea:(Area *)areaToSave {
    
    PersistenceManager *pm = [[PersistenceManager alloc] init];
    
    [pm establishConnection];
    areaToSave.persisted = YES;
    
    // Save area, inventories and observations
    /*if(review) {*/
        if (areaToSave.areaId) {
            [pm updateArea:areaToSave];
            for (Inventory *inventory in areaToSave.inventories) {
                if (inventory.inventoryId) {
                    [pm updateInventory:inventory];
                    for (Observation *observation in inventory.observations) {
                        if (observation.observationId) {
                            [pm updateObservation:observation];
                        } else {
                            observation.inventory = inventory;
                            observation.observationId = [pm saveObservation:observation];
                        }
                    }
                } else {
                    inventory.area = areaToSave;
                    inventory.inventoryId = [pm saveInventory:inventory];
                    for (Observation *observation in inventory.observations) {
                        observation.inventory = inventory;
                        observation.observationId = [pm saveObservation:observation];
                    }
                }
            }
        } else {
            areaToSave.areaId = [pm saveArea:areaToSave];
            [pm saveLocationPoints:areaToSave.locationPoints areaId:areaToSave.areaId];
            for (AreaImage *aImg in areaToSave.pictures) {
                aImg.areaId = areaToSave.areaId;
                aImg.areaImageId = [pm saveAreaImage:aImg];
            }
            for (Inventory *inventory in areaToSave.inventories) {
                inventory.area = areaToSave;
                inventory.inventoryId = [pm saveInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    observation.inventory = inventory;
                    observation.observationId = [pm saveObservation:observation];
                }
            }
        }
    /*} else {
        if (areaToSave.areaId) {
            [pm updateArea:areaToSave];
            for (Inventory *inventory in areaToSave.inventories) {
                if (inventory.inventoryId) {
                    [pm updateInventory:inventory];
                    for (Observation *observation in inventory.observations) {
                        if (observation.observationId) {
                            [pm updateObservation:observation];
                        } else {
                            observation.inventory = inventory;
                            observation.observationId = [pm saveObservation:observation];
                        }
                    }
                } else {
                    inventory.area = areaToSave;
                    inventory.inventoryId = [pm saveInventory:inventory];
                    for (Observation *observation in inventory.observations) {
                        observation.inventory = inventory;
                        observation.observationId = [pm saveObservation:observation];
                    }
                }
            }
        } else {
            areaToSave.areaId = [pm saveArea:areaToSave];
            [pm saveLocationPoints:areaToSave.locationPoints areaId:areaToSave.areaId];
            for (AreaImage *aImg in areaToSave.pictures) {
                aImg.areaId = areaToSave.areaId;
                aImg.areaImageId = [pm saveAreaImage:aImg];
            }
            for (Inventory *inventory in areaToSave.inventories) {
                inventory.area = areaToSave;
                inventory.inventoryId = [pm saveInventory:inventory];
                for (Observation *observation in inventory.observations) {
                    observation.inventory = inventory;
                    observation.observationId = [pm saveObservation:observation];
                }
            }
        }
    }*/
    // Close connection
    [pm closeConnection];
}

- (void) abortArea
{
    NSLog(@"abortArea");
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) newInventory {
    NSLog(@"new inventory pressed");
    if ([area.name compare:@""] == 0) {
        UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageAreaNameTitle", nil)
                                                            message:NSLocalizedString(@"alertMessageAreaName", nil) delegate:self cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [areaAlert show];
        return;
    }
    
    [AreasSubmitController persistArea:area];
    
    // create new inventory if no inventory is choosen
    Inventory *inventory = [[Inventory alloc] getInventory];
    inventory.area = area;
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    NSString *username = @"";
    
    if([appSettings objectForKey:@"username"] != nil) {
        username = [appSettings stringForKey:@"username"];
    }
    inventory.author = username;
    
    // new INVENTORY
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                      initWithNibName:@"AreasSubmitNewInventoryController"
                                      bundle:[NSBundle mainBundle]];
    
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
    [self.navigationController pushViewController:areasSubmitInventoryNameController animated:TRUE];
    areasSubmitInventoryNameController = nil;

    
    // Switch the View & Controller
    //[self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;
}

+ (NSString *) getStringOfDrawMode:(Area*)area {
    switch (area.typeOfArea) {
        case POINT: return @"pin";
        case LINE:
            return @"line";
            break;
        case POLYGON:
            return @"polygon";
    }
    return nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    if (area.areaId) {
        return 3;
    }
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if (section == 0) {
        return [arrayKeys count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath");
    //static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:nil];
    CustomCell *customCell;
    DeleteCell *deleteCell;
    CustomAddCell *customAddCell;
    CustomAreaCell *customAreaCell;
    
    if (indexPath.section == 0) {
        if(indexPath.row != 1) {
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
                        
                    case 0: {
                        CustomDateCell *customDateCell;
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomDateCell" owner:self options:nil];
                        
                        for (id currentObject in topLevelObjects){
                            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                                customDateCell =  (CustomDateCell *)currentObject;
                                break;
                            }
                        }
                        
                        customDateCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customDateCell.value.text = [dateFormatter stringFromDate:area.date];
                        return customDateCell;
                    }
                        
                    case 2:
                    {
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAreaCell" owner:self options:nil];
                        
                        for (id currentObject in topLevelObjects){
                            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                                customAreaCell =  (CustomAreaCell *)currentObject;
                                break;
                            }
                        }
                        customAreaCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customAreaCell.value.text = (area.name.length > 10) ? @"..." : area.name;
                        
                        customAreaCell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:area]]];
                        return customAreaCell;
                    }
                        break;
                        
                    case 3:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (area.description.length > 0) ? @"..." : @"";
                        customCell.image.image = nil;
                    }
                        break;
                        
                    case 4:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        
                        NSString *picCount = [[NSString alloc] initWithFormat:@"%d", area.pictures.count];
                        
                        customCell.value.text = picCount;
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
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            }
            
            // Set up the cell...
            cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [arrayValues objectAtIndex:indexPath.row];
            
            return cell;
        }
    } else if (indexPath.section == 1)
    {
        
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAddCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    customAddCell =  (CustomAddCell *)currentObject;
                    break;
                }
            }

            customAddCell.key.text = NSLocalizedString(@"areaSubmitInventory", nil);
            customAddCell.value.text = [NSString stringWithFormat:@"%i", area.inventories.count];
            [customAddCell.addButton addTarget:self action:@selector(newInventory) forControlEvents:UIControlEventTouchUpInside];

            //[NSString stringWithFormat:@"%i", area.inventories.count];
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
            
            deleteCell.deleteLabel.text = NSLocalizedString(@"areaDelete", nil);
            
            return deleteCell;
        }
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
    NSLog(@"index Path: %@", indexPath);
    AreasSubmitNameController *areasSubmitNameController;
    AreasSubmitDescriptionController *areasSubmitDescriptionController;
    CameraViewController *areaSubmitCameraController;
    AreasSubmitDateController *areasSubmitDateController;
    AreasSubmitInventoryController *areasSubmitInventoryController;
    currIndexPath = indexPath;

    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
            // DATE
            // Create the ObservationsOrganismSubmitDateController
            areasSubmitDateController = [[AreasSubmitDateController alloc] initWithNibName:@"AreasSubmitDateController" bundle:[NSBundle mainBundle]];
            
            areasSubmitDateController.area = area;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:areasSubmitDateController animated:TRUE];
            areasSubmitDateController = nil;
                break;
            }
            case 2:
            {
                // NAME
                // Create the AreasSubmitNameController
                areasSubmitNameController = [[AreasSubmitNameController alloc]
                                                                        initWithNibName:@"AreasSubmitNameController"
                                                                        bundle:[NSBundle mainBundle]];
                
                
                areasSubmitNameController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitNameController animated:TRUE];
                areasSubmitNameController = nil;

                break;
            }
            case 3:
            {
                // DESCRIPTION
                // Create the AreasSubmitDescriptionController
                areasSubmitDescriptionController = [[AreasSubmitDescriptionController alloc]
                                                                                      initWithNibName:@"AreasSubmitDescriptionController"
                                                                                      bundle:[NSBundle mainBundle]];
                
                areasSubmitDescriptionController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitDescriptionController animated:TRUE];
                areasSubmitDescriptionController = nil;

                break;
            }
            case 4:
            {
                // CAMERA
                // Create the AreaSubmitCameraController
                areaSubmitCameraController = [[CameraViewController alloc]
                                                                    initWithNibName:@"CameraViewController"
                                                                    bundle:[NSBundle mainBundle]];
                
                
                areaSubmitCameraController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areaSubmitCameraController animated:TRUE];
                areaSubmitCameraController = nil;
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        
    // INVENTORY
        if ([area.name compare:@""] == 0) {
            UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageAreaNameTitle", nil)
                                                                message:NSLocalizedString(@"alertMessageAreaName", nil) delegate:self cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
            [areaAlert show];
            return;
        } else {
            [AreasSubmitController persistArea:area];
        }



        // Create the AreasSubmitInventoryController
        areasSubmitInventoryController = [[AreasSubmitInventoryController alloc]
                                                                                initWithNibName:@"AreasSubmitInventoryController"
                                                                                bundle:[NSBundle mainBundle]];
        
        areasSubmitInventoryController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitInventoryController animated:TRUE];
        areasSubmitInventoryController = nil;
    } else {
        if (!deleteAreaSheet) {
            deleteAreaSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:NSLocalizedString(@"areaDelete", nil) otherButtonTitles: nil];
            
            deleteAreaSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        [deleteAreaSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

#pragma mark
#pragma UIAlertViewDelegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //ok pressed
        NSLog(@"delete Area");
        [persistenceManager establishConnection];
        [persistenceManager deleteArea:area.areaId];
        [persistenceManager closeConnection];
        
        [area setArea:nil];
        
        /*if (!areasViewController) {
            areasViewController = [[AreasViewController alloc]
                                   initWithNibName:@"AreasViewController"
                                   bundle:[NSBundle mainBundle] area:area];
        }*/
        
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

            
            UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"areaDelete", nil)
                                                                message:NSLocalizedString(@"areaDeleteMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil)
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
