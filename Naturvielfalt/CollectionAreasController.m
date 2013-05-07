//
//  CollectionAreasController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import "CollectionAreasController.h"
#import "AreasSubmitController.h"
#import "CheckboxAreaCell.h"
#import "Area.h"
#import "Reachability.h"

@interface CollectionAreasController ()

@end

@implementation CollectionAreasController
@synthesize tableView, areas;

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
    NSString *title = NSLocalizedString(@"areaTabLabel", nil);
    self.navigationItem.title = title;
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navSubmit", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(alertOnSendAreasDialog)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    
    tableView.delegate = self;
    
    // Reload the areas
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    [self reloadAreas];
    
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
    [self beginLoadingAreas];
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
- (void) alertOnSendAreasDialog{
    doSubmit = TRUE;
    if([self connectedToWiFi]){
        [self sendAreas];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertAreaTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertAreaDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(doSubmit){
        if (buttonIndex == 1){
            [self sendAreas];
        }
        doSubmit = FALSE;
    }
}

- (void) sendAreas {
    NSLog(@"send Areas");
}

- (void) reloadAreas
{
    // Reset observations
    areas = nil;
    
    [self beginLoadingAreas];
}

- (void)beginLoadingAreas
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadAreas) object:nil];
    [operationQueue addOperation:operation];
}

- (void)synchronousLoadAreas
{
    // Establish a connection
    [persistenceManager establishConnection];
    
    // Get all observations
    NSMutableArray *arrNewAreas = [persistenceManager getAreas];
    
    [persistenceManager closeConnection];
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingAreas:) withObject:arrNewAreas waitUntilDone:YES];
}

- (void)didFinishLoadingAreas:(NSMutableArray *)arrNewAreas {
    
    if(areas != nil){
        if([areas count] != [arrNewAreas count]){
            areas = arrNewAreas;
        }
    }
    else {
        areas = arrNewAreas;
    }
    
    countAreas = (int *)self.areas.count;
    
    if(tableView.editing)
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    
    [tableView reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([areas count] < 1) {
        tableView.editing = FALSE;
    }
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxAreaCell *cell = (CheckboxAreaCell *)[tv cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        Area *area = [persistenceManager getArea:button.tag];
        
        // If Yes, delete the areas with the persistence manager and all inventories and observations from area
        for (Inventory *inventory in area.inventories) {
            [persistenceManager deleteObservations:inventory.observations];
        }
        [persistenceManager deleteInventories:area.inventories];
        [persistenceManager deleteArea:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        // Reload the areas from the database and refresh the TableView
        [self reloadAreas];
    }
}

#pragma UITableViewDelegates methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [areas count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CheckboxAreaCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout
    CheckboxAreaCell *checkboxAreaCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxAreaCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxAreaCell =  (CheckboxAreaCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxAreaCell = (CheckboxAreaCell *)cell;
    }
    
    Area *area = [areas objectAtIndex:indexPath.row];
    
    if(area != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:area.date];
        
        if(area.pictures.count > 0){
            UIImage *original = (UIImage *)[area.pictures objectAtIndex:0];
            CGFloat scale = [UIScreen mainScreen].scale;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef context = CGBitmapContextCreate(NULL, 26, 26, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
            CGContextDrawImage(context,
                               CGRectMake(0, 0, 26, 26 * scale),
                               original.CGImage);
            CGImageRef shrunken = CGBitmapContextCreateImage(context);
            UIImage *final = [UIImage imageWithCGImage:shrunken];
            
            CGContextRelease(context);
            CGImageRelease(shrunken);
            checkboxAreaCell.image.image = final;
        }
        else {
            checkboxAreaCell.image.image = [UIImage imageNamed:@"blank.png"];
        }

        checkboxAreaCell.title.text = area.name;
        checkboxAreaCell.date.text = nowString;
        checkboxAreaCell.count.text = [NSString stringWithFormat:@"%i", area.inventories.count];
        checkboxAreaCell.subtitle.text = area.author;
        
        // Set the image of area type
        checkboxAreaCell.areaMode.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:area]]];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaCell.checkbox setTag:area.areaId];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaCell.remove setTag:area.areaId];
        
        // Set checkbox icon
        if(area.submitToServer) {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }
    }
    
    return checkboxAreaCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
    NSLog(@"checkboxEvent");
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Area *area in areas) {
        if(area.areaId == [number longLongValue]) {
            area.submitToServer = !area.submitToServer;
        }
    }
    
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    AreasSubmitController *areasSubmitController = [[AreasSubmitController alloc]
                                                                      initWithNibName:@"AreasSubmitController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Area *area = [areas objectAtIndex:indexPath.row];
    
    // Store the current observation object
    Area *areaShared = [[Area alloc] getArea];
    [areaShared setArea:area];
    
    NSLog(@"Observation in CollectionOverView: %@", [areaShared getArea]);
    
    // Set the current displayed organism
    areasSubmitController.area = area;
    areasSubmitController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitController animated:TRUE];
    areasSubmitController = nil;
}

@end
