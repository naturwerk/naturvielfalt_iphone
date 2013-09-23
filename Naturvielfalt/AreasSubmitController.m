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
#import "CustomAddCell.h"
#import "CustomAreaCell.h"
#import "DeleteCell.h"
#import <QuartzCore/QuartzCore.h>

#define numOfRowInSectionNull     2
#define numOfRowInSectionOne      3
#define numOfRowInSectionTwo      1
#define numOfRowInSectionThree    1

#define numOfSections             4

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
    
    /*loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudSaveMessage", nil);
    
    [loadingHUD showWhileExecuting:@selector(persistArea:) onTarget:self withObject:nil animated:YES];*/

    
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
    arrayKeysSectionNull = [[NSArray alloc] initWithObjects:NSLocalizedString(@"areaSubmitTime", nil), NSLocalizedString(@"areaSubmitAuthor", nil), nil];
    
    arrayKeysSectionOne = [[NSArray alloc] initWithObjects:NSLocalizedString(@"areaSubmitName", nil), NSLocalizedString(@"areaSubmitDescr", nil), NSLocalizedString(@"areaSubmitImages", nil), nil];
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
            [self.navigationController popViewControllerAnimated:YES];
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
        [self.navigationController pushViewController:areasSubmitNameController animated:YES];
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
    
    [persistenceManager establishConnection];
    [persistenceManager persistArea:area];
    [persistenceManager closeConnection];
    
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
    review = YES;
    
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

    [self.navigationController popViewControllerAnimated:YES];
}

- (void) abortArea
{
    NSLog(@"abortArea");
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [persistenceManager establishConnection];
    [persistenceManager persistArea:area];
    [persistenceManager closeConnection];
    
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
    [self.navigationController pushViewController:areasSubmitInventoryNameController animated:YES];
    areasSubmitInventoryNameController = nil;

    
    // Switch the View & Controller
    //[self.navigationController pushViewController:areasSubmitNewInventoryController animated:YES];
    areasSubmitNewInventoryController = nil;
}

+ (NSString *) getStringOfDrawMode:(Area*)area {
    switch (area.typeOfArea) {
        case POINT: return @"pin"; break;
        case LINE: return @"line"; break;
        case POLYGON: return @"polygon"; break;
    }
    return nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (area.areaId) {
        return numOfSections;
    }
    return numOfSections - 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return numOfRowInSectionNull; break;
        case 1: return numOfRowInSectionOne; break;
        case 2: return numOfRowInSectionTwo; break;
        case 3: return numOfRowInSectionThree; break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:nil];
    CustomCell *customCell;
    DeleteCell *deleteCell;
    CustomAddCell *customAddCell;
    CustomAreaCell *customAreaCell;
    CustomDateCell *customDateCell;
    
    NSArray *topLevelObjects;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: { // Date
                    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomDateCell" owner:self options:nil];
                    
                    for (id currentObject in topLevelObjects){
                        if ([currentObject isKindOfClass:[UITableViewCell class]]){
                            customDateCell =  (CustomDateCell *)currentObject;
                            break;
                        }
                    }
                    
                    customDateCell.key.text = [arrayKeysSectionNull objectAtIndex:indexPath.row];
                    customDateCell.value.text = [dateFormatter stringFromDate:area.date];
                    return customDateCell;
                }
                    break;
                    
                case 1: { // Observator
                    // Use normal cell layout
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    }
                    
                    // Set up the cell...
                    cell.textLabel.text = [arrayKeysSectionNull objectAtIndex:indexPath.row];
                    cell.detailTextLabel.text = (area.author.length > 0) ? area.author : @"-";
                    cell.userInteractionEnabled = NO;
                    
                    return cell;
                }
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0: { // Area name
                    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAreaCell" owner:self options:nil];
                    
                    for (id currentObject in topLevelObjects){
                        if ([currentObject isKindOfClass:[UITableViewCell class]]){
                            customAreaCell =  (CustomAreaCell *)currentObject;
                            break;
                        }
                    }
                    customAreaCell.key.text = [arrayKeysSectionOne objectAtIndex:indexPath.row];
                    customAreaCell.value.text = (area.name.length > 10) ? @"..." : area.name;
                    
                    customAreaCell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:area]]];
                    return customAreaCell;
                }
                    break;
                    
                case 1: { // Description
                    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                    
                    for (id currentObject in topLevelObjects){
                        if ([currentObject isKindOfClass:[UITableViewCell class]]){
                            customCell =  (CustomCell *)currentObject;
                            break;
                        }
                    }
                    
                    customCell.key.text = [arrayKeysSectionOne objectAtIndex:indexPath.row];
                    customCell.value.text = (area.description.length > 0) ? @"..." : @"-";
                    customCell.image.image = nil;
                    
                    return customCell;
                }
                    break;
                    
                case 2: { // Photo of Area
                    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                    
                    for (id currentObject in topLevelObjects){
                        if ([currentObject isKindOfClass:[UITableViewCell class]]){
                            customCell =  (CustomCell *)currentObject;
                            break;
                        }
                    }
                    
                    customCell.key.text = [arrayKeysSectionOne objectAtIndex:indexPath.row];
                    NSString *picCount = [[NSString alloc] initWithFormat:@"%d", area.pictures.count];
                    customCell.value.text = picCount;
                    customCell.image.image = nil;
                    
                    return customCell;
                }
                    break;
            }
            break;
            
        case 2: { // Inventories
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAddCell" owner:self options:nil];
            
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
            break;
        
        case 3: { // Delete
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
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        CAGradientLayer *gradientLayerUnselected;
        UIColor *lighterColorUnselected = [UIColor colorWithRed:225/255.0 green:132/255.0 blue:133/255.0 alpha:1];
        UIColor *darkerColorUnselected = [UIColor colorWithRed:175/255.0 green:10/255.0 blue:12/255.0 alpha:1];
        
        gradientLayerUnselected = [CAGradientLayer layer];
        gradientLayerUnselected.cornerRadius = 8;
        gradientLayerUnselected.frame = CGRectMake(10, 0, 300, 44);
        gradientLayerUnselected.colors = [NSArray arrayWithObjects:(id)[lighterColorUnselected CGColor], (id)[darkerColorUnselected CGColor], nil];
        [cell.layer insertSublayer:gradientLayerUnselected atIndex:0];
    }
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

    switch (indexPath.section) {
        case 0: {
            // DATE
            // Create the ObservationsOrganismSubmitDateController
            areasSubmitDateController = [[AreasSubmitDateController alloc] initWithNibName:@"AreasSubmitDateController" bundle:[NSBundle mainBundle]];
            
            areasSubmitDateController.area = area;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:areasSubmitDateController animated:YES];
            areasSubmitDateController = nil;
        }
            break;
            
        case 1: {
            switch (indexPath.row) {
                case 0: { // Area name
                    // NAME
                    // Create the AreasSubmitNameController
                    areasSubmitNameController = [[AreasSubmitNameController alloc]
                                                 initWithNibName:@"AreasSubmitNameController"
                                                 bundle:[NSBundle mainBundle]];
                    
                    
                    areasSubmitNameController.area = area;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:areasSubmitNameController animated:YES];
                    areasSubmitNameController = nil;
                }
                    break;
                    
                case 1: { // Description
                    // DESCRIPTION
                    // Create the AreasSubmitDescriptionController
                    areasSubmitDescriptionController = [[AreasSubmitDescriptionController alloc]
                                                        initWithNibName:@"AreasSubmitDescriptionController"
                                                        bundle:[NSBundle mainBundle]];
                    
                    areasSubmitDescriptionController.area = area;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:areasSubmitDescriptionController animated:YES];
                    areasSubmitDescriptionController = nil;
                }
                    break;
                    
                case 2: { // Photo of area
                    // CAMERA
                    // Create the AreaSubmitCameraController
                    areaSubmitCameraController = [[CameraViewController alloc]
                                                  initWithNibName:@"CameraViewController"
                                                  bundle:[NSBundle mainBundle]];
                    
                    
                    areaSubmitCameraController.area = area;
                    
                    // Switch the View & Controller
                    [self.navigationController pushViewController:areaSubmitCameraController animated:YES];
                    areaSubmitCameraController = nil;
                }
                    break;
            }
        }
            break;
            
        case 2: {
            // INVENTORY
            if ([area.name compare:@""] == 0) {
                UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageAreaNameTitle", nil)
                                                                    message:NSLocalizedString(@"alertMessageAreaName", nil) delegate:self cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
                [areaAlert show];
                return;
            }
            
            // Create the AreasSubmitInventoryController
            areasSubmitInventoryController = [[AreasSubmitInventoryController alloc]
                                              initWithNibName:@"AreasSubmitInventoryController"
                                              bundle:[NSBundle mainBundle]];
            
            areasSubmitInventoryController.area = area;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:areasSubmitInventoryController animated:YES];
            areasSubmitInventoryController = nil;
        }
            break;
            
        case 3: {
            if (!deleteAreaSheet) {
                deleteAreaSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil) destructiveButtonTitle:NSLocalizedString(@"areaDelete", nil) otherButtonTitles: nil];
                
                deleteAreaSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            }
            [deleteAreaSheet showFromTabBar:self.tabBarController.tabBar];
        }
            break;
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
        
        [self.navigationController popViewControllerAnimated:YES];
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
