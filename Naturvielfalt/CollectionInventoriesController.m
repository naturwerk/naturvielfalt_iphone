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

@interface CollectionInventoriesController ()

@end

@implementation CollectionInventoriesController
@synthesize tableView, inventories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
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
    
    // Reload the observations
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

- (void) reloadInventories {
    NSLog(@"reload inventories");
    
    // Reset observations
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
        checkboxInventoryCell.subtitle.text = inventory.author;
        
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

- (void) checkboxEvent {
    NSLog(@"checkboxEvent");
}

- (void) removeEvent {
    NSLog(@"removeEvent");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}
@end
