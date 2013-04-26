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
#import "AreasViewController.h"
#import "CameraViewController.h"
#import "CustomCell.h"
#import "MBProgressHUD.h"
#import "CustomAddCell.h"
#import "CustomAreaCell.h"

@interface AreasSubmitController ()

@end

@implementation AreasSubmitController
@synthesize areaChanged, area, tableView, drawMode, customAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"load settings for save area view");
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Sichern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button  
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Abbrechen"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortArea)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set navigation bar title    
    NSString *title = @"Gebiet";
    self.navigationItem.title = title;
    
    // Table init
    tableView.delegate = self;
    
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    [self prepareData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareData 
{
    
    NSString *nowString;
    
    if(!review) {
        
        /*NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        NSString *username = @"";
        
        if([appSettings objectForKey:@"username"] != nil) {
            username = [appSettings stringForKey:@"username"];
        }
        NSLog(@"Benutzername: %@", username);
        area.author = username;*/
        
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in area data object
        area.date = now;
    }
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:area.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:@"Zeit", @"Erfasser", @"Gebietsname", @"Beschreibung",  @"Gebietsfotos", nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, area.author, area.name, area.description, @">", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (area.persisted) {
        // Set top navigation bar button
        UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Ändern"
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action: @selector(saveArea)];
        self.navigationItem.rightBarButtonItem = submitButton;
    }
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void) saveArea
{
    
    NSLog(@"saveArea");
    if (!persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
    }
    area.persisted = YES;

    // Save area
    if(review) {
        [persistenceManager updateArea:area];
    } else {
        area.areaId = [persistenceManager saveArea:area];
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
    hud.labelText = @"Gebiet gespeichert";
    
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Sichern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];;


    if (!areasViewController) {
        areasViewController = [[AreasViewController alloc]
                                                    initWithNibName:@"AreasViewController"
                                                    bundle:[NSBundle mainBundle] area:area];
    }
    
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:areasViewController animated:TRUE];

}

- (void) abortArea
{
    NSLog(@"abortArea");
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
    
    if (!areasViewController) {
        areasViewController = [[AreasViewController alloc]
                               initWithNibName:@"AreasViewController"
                               bundle:[NSBundle mainBundle] area:area];
    }
}

- (void) newInventory {
    NSLog(@"new inventory pressed");
    // new INVENTORY
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                      initWithNibName:@"AreasSubmitNewInventoryController"
                                      bundle:[NSBundle mainBundle]];
    
    areasSubmitNewInventoryController.area = area;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;
}

- (NSString *) getStringOfDrawMode {
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
    static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    CustomCell *customCell;
    CustomAddCell *customAddCell;
    CustomAreaCell *customAreaCell;
    
    if (indexPath.section == 0) {
        if(indexPath.row > 1) {
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
                        
                        customAreaCell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [self getStringOfDrawMode]]];
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
            customAddCell.key.text = @"Inventare";
            NSLog(@"%i", area.inventories.count);
            customAddCell.value.text = [NSString stringWithFormat:@"%i", area.inventories.count];
            [customAddCell.addButton addTarget:self action:@selector(newInventory) forControlEvents:UIControlEventTouchUpInside];

            //[NSString stringWithFormat:@"%i", area.inventories.count];
            return customAddCell;
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
    AreasSubmitInventoryController *areasSubmitInventoryController;

    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 2:
                // NAME
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitNameController = [[AreasSubmitNameController alloc]
                                                                        initWithNibName:@"AreasSubmitNameController"
                                                                        bundle:[NSBundle mainBundle]];
                
                
                areasSubmitNameController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitNameController animated:TRUE];
                areasSubmitNameController = nil;

                break;
            case 3:
                // DESCRIPTION
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitDescriptionController = [[AreasSubmitDescriptionController alloc]
                                                                                      initWithNibName:@"AreasSubmitDescriptionController"
                                                                                      bundle:[NSBundle mainBundle]];
                
                areasSubmitDescriptionController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitDescriptionController animated:TRUE];
                areasSubmitDescriptionController = nil;

                break;
            case 4:
                // CAMERA
                // Create the ObservationsOrganismSubmitCameraController
                areaSubmitCameraController = [[CameraViewController alloc]
                                                                    initWithNibName:@"CameraViewController"
                                                                    bundle:[NSBundle mainBundle]];
                
                
                areaSubmitCameraController.area = area;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areaSubmitCameraController animated:TRUE];
                areaSubmitCameraController = nil;
                break;
            default:
                break;
        }
    } else {

        // INVENTORY
        // Create the ObservationsOrganismSubmitMapController
        areasSubmitInventoryController = [[AreasSubmitInventoryController alloc]
                                                                                initWithNibName:@"AreasSubmitInventoryController"
                                                                                bundle:[NSBundle mainBundle]];
        
        areasSubmitInventoryController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitInventoryController animated:TRUE];
        areasSubmitInventoryController = nil;
    }
}
@end
