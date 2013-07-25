//
//  CollectionAreasController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import "CollectionAreasController.h"
#import "AreasSubmitController.h"
#import "AreaUploadHelper.h"
#import "CheckboxAreaCell.h"
#import "Area.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>

@interface CollectionAreasController ()

@end

@implementation CollectionAreasController
@synthesize table, areas, checkAllButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        doSubmit = FALSE;
        persistenceManager = [[PersistenceManager alloc] init];
    }
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
    
    table.delegate = self;
    [checkAllButton setTag:1];
    
    // Reload the areas
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //[self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadAreas) onTarget:self withObject:nil animated:YES];
    
    [table reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [self setCheckAllButton:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = FALSE;
    [self reloadAreas];
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
    
    // Get username and password from the UserDefaults
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [appSettings stringForKey:@"username"];
    NSString *password = [appSettings stringForKey:@"password"];
    
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil)
                                                              message:NSLocalizedString(@"collectionAlertErrorSettings", nil) delegate:self cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
        return;
    }
    
    uploadView = [[AlertUploadView alloc] initWithTitle:NSLocalizedString(@"collectionHudWaitMessage", nil) message:NSLocalizedString(@"collectionHudSubmitMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil) otherButtonTitles:nil];
    /*UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
     pv.frame = CGRectMake(40, 67, 200, 15);
     CGAffineTransform myTransform = CGAffineTransformMakeScale(1.0, 2.0f);
     pv.progress = 0.5;
     [uploadView addSubview:pv];*/
    [uploadView show];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
     [self.navigationController.view addSubview:loadingHUD];
     
     loadingHUD.delegate = self;
     loadingHUD.mode = MBProgressHUDModeCustomView;
     loadingHUD.labelText = NSLocalizedString(@"collectionHudWaitMessage", nil);
     loadingHUD.detailsLabelText = NSLocalizedString(@"collectionHudSubmitMessage", nil);
     
     //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     [loadingHUD show:YES];*/
    [self sendRequestToServer];
    
    //[loadingHUD showWhileExecuting:@selector(sendRequestToServer) onTarget:self withObject:nil animated:YES];

}

- (void) sendRequestToServer
{
    // check username and password from the UserDefaults
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [appSettings objectForKey:@"username"];
    NSString *password = [appSettings objectForKey:@"password"];
    
    if((username.length == 0) || (password.length == 0)) {
        
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorSettings", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //new portal
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    
    areasToSubmit = [[NSMutableArray alloc] init];
    for (Area *area in areas) {
        if (area.submitToServer) {
            [areasToSubmit addObject:area];
        }
    }
    totalObjectsToSubmit = [self getTotalObjectOfSubmission:areasToSubmit];
    areasCounter = areasToSubmit.count;
    totalRequests = areasCounter;
    
    if(areasCounter == 0) {
        [loadingHUD removeFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorObs", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (!areaUploadHelpers) {
        areaUploadHelpers = [[NSMutableArray alloc] init];
    }
    
    for (Area *area in areasToSubmit) {
            AreaUploadHelper *areaUploadHelper = [[AreaUploadHelper alloc] init];
            [areaUploadHelper registerListener:self];
            [areaUploadHelpers addObject:areaUploadHelper];
            [areaUploadHelper submit:area withRecursion:YES];
    }
}

- (int) getTotalObjectOfSubmission:(NSMutableArray *) array {
    int totalObjects = 0;
    for (Area *area in array) {
        for (Inventory *inventory in area.inventories) {
            totalObjects += inventory.observations.count;
        }
        totalObjects += area.inventories.count;
    }
    totalObjects += array.count;
    return totalObjects;
}

- (void) reloadAreas
{
    // Reset observations
    areas = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([areas count] < 1) {
        table.editing = FALSE;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
            UIImage *original = ((AreaImage *)[area.pictures objectAtIndex:0]).image;
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
        
        if (area.submitted) {
            checkboxAreaCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxAreaCell.submitted.hidden = NO;
            checkboxAreaCell.submitted.text = NSLocalizedString(@"navSubmitted", nil);
            [checkboxAreaCell.count setAlpha:0.2f];
            [checkboxAreaCell.date setAlpha:0.2f];
            [checkboxAreaCell.image setAlpha:0.2f];
            checkboxAreaCell.checkbox.hidden = YES;
            area.submitToServer = NO;
        }
        
        // Set checkbox icon
        if(area.submitToServer) {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.png"];
        }
        

    }
    
    checkboxAreaCell.layer.shouldRasterize = YES;
    checkboxAreaCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
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
    
    [table reloadData];
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

# pragma Listener methods
- (void)notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer>) observer {
    [observer unregisterListener];
    if (object.class != [Area class]) {
        return;
    }
    Area *area = (Area *) object;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    float percent = (100 / totalRequests) * (totalRequests - (--areasCounter));
    NSLog(@"requestcounter: %d progress: %f",areasCounter + 1,  percent / 100);
    uploadView.progressView.progress = percent / 100;
    
    //Save received guid in object, not persisted yet
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
    NSString *successString;
    if ([matches count] > 0) {
        successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
    } else {
        NSLog(@"ERROR: NO GUID received!!");
    }
    
    if ([successString isEqualToString:@"success=1"]) {
        
         // update area (guid)
         @synchronized (self) {
         [persistenceManager establishConnection];
         [persistenceManager updateArea:area];
         [persistenceManager closeConnection];
         }
        
        // Reload observations
        [self reloadAreas];
        [areasToSubmit removeObject:area];
    }
    
    if (areasCounter == 0) {
        [areaUploadHelpers removeAllObjects];
        
        if (areasToSubmit.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navSuccess", nil) message:NSLocalizedString(@"collectionSuccessAreaDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorAreSubmit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
            [alert show];
        }
        //[loadingHUD removeFromSuperview];
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}


- (IBAction)checkAllAreas:(id)sender {
    int currentTag = checkAllButton.tag;
    
    if (currentTag == 0) {
        [checkAllButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        for (Area *area in areas) {
            area.submitToServer = YES;
        }
        checkAllButton.tag = 1;
    } else {
        [checkAllButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        for (Area *area in areas) {
            area.submitToServer = NO;
        }
        checkAllButton.tag = 0;
    }
    [table reloadData];
}
@end
