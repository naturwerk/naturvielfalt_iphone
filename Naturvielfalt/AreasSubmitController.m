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
#import "CameraViewController.h"
#import "CustomCell.h"
#import "MBProgressHUD.h"

@interface AreasSubmitController ()

@end

@implementation AreasSubmitController
@synthesize areaChanged, area, tableView, arrayKeys, arrayValues, persistenceManager, review;

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
    // Do any additional setup after loading the view from its nib.
    NSLog(@"load settings for save area view");
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:(!review) ? @"Sichern" 
                                     : @"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button  
    UIBarButtonItem *chancelButton = [[UIBarButtonItem alloc] 
                                      initWithTitle:@"Abbrechen"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortArea)];
    self.navigationItem.leftBarButtonItem = chancelButton;
    
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
    // Create new area object, will late be used as data transfer object
    if(!area) area = [[[Area alloc] init] getArea];
    
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
        
        // Update date in observation data object
        area.date = now;
    }
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:area.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:@"Zeit", @"Erfasser", @"Gebietsname", @"Beschreibung",  @"Gebietsfotos", nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, area.author, area.areaName, area.description, @">", nil];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void) saveArea
{
    NSLog(@"saveArea");
    if (persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
    }

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
    [hud hide:YES afterDelay:3];
    
    // Set review flag
    review = true;
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveObservation)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    [tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.parentViewController animated:TRUE];
}

- (void) abortArea
{
    NSLog(@"abortArea");
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
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
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = area.areaName;
                        customCell.image.image = nil;
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
                        
                    case 5:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = area.inventoryName;
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
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    customCell =  (CustomCell *)currentObject;
                    break;
                }
            }

            NSLog(@"section %i", indexPath.section);
            customCell.key.text = @"Inventare verwalten";
            customCell.value.text = @"5";
            customCell.image.image = nil;
            return customCell;
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
    // TODO: rewrite to switch case!
    if (indexPath.row == 2) {
        // NAME
        // Create the ObservationsOrganismSubmitCameraController
        AreasSubmitNameController *areasSubmitNameController = [[AreasSubmitNameController alloc]
                                                                                      initWithNibName:@"AreasSubmitNameController"
                                                                                      bundle:[NSBundle mainBundle]];
        
        
        areasSubmitNameController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitNameController animated:TRUE];
        areasSubmitNameController = nil;
        
    }  else if (indexPath.row == 3) {
        // DESCRIPTION
        // Create the ObservationsOrganismSubmitCameraController
        AreasSubmitDescriptionController *areasSubmitDescriptionController = [[AreasSubmitDescriptionController alloc]
                                                                                        initWithNibName:@"AreasSubmitDescriptionController"
                                                                                        bundle:[NSBundle mainBundle]];
        
        areasSubmitDescriptionController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitDescriptionController animated:TRUE];
        areasSubmitDescriptionController = nil;
        
    } else if (indexPath.row == 4) {
        // CAMERA
        // Create the ObservationsOrganismSubmitCameraController
        CameraViewController *areaSubmitCameraController = [[CameraViewController alloc]
                                                                initWithNibName:@"CameraViewController"
                                                                bundle:[NSBundle mainBundle]];
        
        
        areaSubmitCameraController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areaSubmitCameraController animated:TRUE];
        areaSubmitCameraController = nil;
        
    } else if(indexPath.row == 5) {
        // INVENTORY
        // Create the ObservationsOrganismSubmitMapController
        AreasSubmitInventoryController *areasSubmitInventoryController = [[AreasSubmitInventoryController alloc]
                                                                                initWithNibName:@"AreasSubmitInventoryController"
                                                                                bundle:[NSBundle mainBundle]];
        
        areasSubmitInventoryController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitInventoryController animated:TRUE];
        areasSubmitInventoryController = nil;
    }
}
@end
