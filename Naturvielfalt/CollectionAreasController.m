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

#define SUCCESS 200

@implementation CollectionAreasController
@synthesize table, areas, checkAllButton, checkAllView, noEntryFoundLabel;

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
    
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    // Reload the areas
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    /*loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadAreas) onTarget:self withObject:nil animated:YES];*/
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxAreaCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxAreaCell"];
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
    [self setCheckAllView:nil];
    [self setNoEntryFoundLabel:nil];
    areas = nil;
    areaUploadHelpers = nil;
    areasToSubmit = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = NO;

    loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    loadingHUD.mode = MBProgressHUDModeCustomView;
    [self reloadAreas];
}

//Check if there is an active WiFi connection
- (BOOL) connectedToWiFi{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = NO;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = YES;
	}
	
	return result;
}

//Check if there is an active internet connection (3G OR WIFI)
- (BOOL) connectedToInternet{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = false;
	
	if (internetStatus != NotReachable)
	{
	    result = true;
	}
	
	return result;
}

//fires an alert if not connected to WiFi
- (void) alertOnSendAreasDialog{
    doSubmit = TRUE;
    if(![self connectedToInternet]) {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertNoInternetTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertNoInternetDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)
                                                    otherButtonTitles:nil , nil];
        [submitAlert show];
    }
    else if([self connectedToWiFi]){
        [self sendAreas];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertObsTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertObsDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == uploadView) {
        cancelSubmission = YES;
        for (AreaUploadHelper *areaUploadHelper in areaUploadHelpers) {
            [areaUploadHelper cancel];
        }
        
        ((AlertUploadView*) alertView).keepAlive = YES;
        
        alertView.title = NSLocalizedString(@"collectionHudWaitMessage", nil);
        alertView.message = NSLocalizedString(@"collectionHudFinishingRequests", nil);
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"collectionAlertObsTitle", nil)]) {
            if(doSubmit){
                if (buttonIndex == 1){
                    [self sendAreas];
                }
                doSubmit = NO;
            }
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
    
    areasToSubmit = [[NSMutableArray alloc] init];
    for (Area *area in areas) {
        if (area.submitToServer) {
            [areasToSubmit addObject:area];
        }
    }
    
    areasToSubmit = [[NSMutableArray alloc] init];
    for (Area *area in areas) {
        if (area.submitToServer) {
            [areasToSubmit addObject:area];
        }
    }
    areasCounter = areasToSubmit.count;
    
    if(areasCounter == 0) {
        uploadView.keepAlive = NO;
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorAreas", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    uploadView = [[AlertUploadView alloc] initWithTitle:NSLocalizedString(@"collectionHudWaitMessage", nil) message:NSLocalizedString(@"collectionHudSubmitMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil) otherButtonTitles:nil];
    /*UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
     pv.frame = CGRectMake(40, 67, 200, 15);
     CGAffineTransform myTransform = CGAffineTransformMakeScale(1.0, 2.0f);
     pv.progress = 0.5;
     [uploadView addSubview:pv];*/
    [uploadView show];
    
    [self sendRequestToServer];

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
    
    
    totalObjectsToSubmit = [self getTotalObjectOfSubmission:areasToSubmit];
    areasCounter = areasToSubmit.count;
    totalRequests = areasCounter;
    
    if (!areaUploadHelpers) {
        areaUploadHelpers = [[NSMutableArray alloc] init];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        loadingHUD.labelText = NSLocalizedString(@"Check for autorisation", nil);
        loadingHUD.mode = MBProgressHUDModeCustomView;
    });
    
    if (/*!cancelSubmission &&*/ [self checkLoginData:username andPWD:password]) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        for (Area *area in areasToSubmit) {
            AreaUploadHelper *areaUploadHelper = [[AreaUploadHelper alloc] init];
            [areaUploadHelper registerListener:self];
            [areaUploadHelpers addObject:areaUploadHelper];
            [areaUploadHelper submit:area withRecursion:YES];
        }
    } else {
        [loadingHUD removeFromSuperview];
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:@"keine Autorisierung" delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

- (BOOL) checkLoginData: (NSString *)username andPWD: (NSString *)pwd {
    
    NSURL *url = [NSURL URLWithString:@"https://naturvielfalt.ch/webservice/api/login"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUsername:username];
    [request setPassword:pwd];
    [request setValidatesSecureCertificate: YES];
    request.delegate = self;
    
    [request startSynchronous];
    return authorized;
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    authorized = (request.responseStatusCode == 200) ? YES: NO;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    authorized = NO;
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

    // Reset areas
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
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([areas count] < 1) {
        table.editing = NO;
        table.hidden = YES;
        noEntryFoundLabel.hidden = NO;
    } else {
        table.hidden = NO;
        noEntryFoundLabel.hidden = YES;
    }
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
        [areas removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([areas count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        //[self reloadAreas];
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
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CheckboxAreaCell" forIndexPath:indexPath];
    
    // use CustomCell layout
    CheckboxAreaCell *checkboxAreaCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxAreaCell" owner:self options:nil];
        
        checkboxAreaCell =  (CheckboxAreaCell *)topLevelObjects[0];
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
            checkboxAreaCell.image.contentMode = UIViewContentModeScaleAspectFit;
            checkboxAreaCell.image.image = ((ObservationImage *)[area.pictures objectAtIndex:0]).image;
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
        
        
        if (area.submitted && [area checkAllInventoriesFromAreaSubmitted]) {
            checkboxAreaCell.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
            checkboxAreaCell.submitted.hidden = NO;
            checkboxAreaCell.submitted.text = NSLocalizedString(@"navSubmitted", nil);
            [checkboxAreaCell.count setAlpha:0.4f];
            [checkboxAreaCell.date setAlpha:0.4f];
            [checkboxAreaCell.image setAlpha:0.4f];
            checkboxAreaCell.checkbox.hidden = YES;
            checkboxAreaCell.checkboxView.hidden = YES;
            area.submitToServer = NO;
        } else {
            checkboxAreaCell.contentView.backgroundColor = [UIColor clearColor];
            checkboxAreaCell.submitted.hidden = YES;
            [checkboxAreaCell.count setAlpha:1];
            [checkboxAreaCell.date setAlpha:1];
            [checkboxAreaCell.image setAlpha:1];
            checkboxAreaCell.checkbox.hidden = NO;
            checkboxAreaCell.checkboxView.hidden = NO;
            //area.submitToServer = YES;
        }
    }
    
    // Set checkbox icon
    if(area.submitToServer) {
        //[checkboxAreaCell.checkbox setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal] ;
        [checkboxAreaCell.checkboxView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];
    } else {
        //[checkboxAreaCell.checkbox setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal] ;
        [checkboxAreaCell.checkboxView setImage:[UIImage imageNamed:@"checkbox.png"]];
    }

    checkboxAreaCell.layer.shouldRasterize = YES;
    checkboxAreaCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return checkboxAreaCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
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
    [self.navigationController pushViewController:areasSubmitController animated:YES];
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
    
    if ([response isEqualToString:@"cancel"]) {
        [areasToSubmit removeObject:area];
        
    } else {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
        NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
        NSString *successString;
        if ([matches count] > 0) {
            successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
        } else {
            NSLog(@"ERROR: NO GUID received!! response: %@", response);
        }
        
        if ([successString isEqualToString:@"success=1"]) {
            [areasToSubmit removeObject:area];
            // Reload observations
            [self reloadAreas];
        }
    }
        
    if (areasCounter == 0) {
        [areaUploadHelpers removeAllObjects];
        if (areasToSubmit.count == 0 && !submissionFail) {
            if (!cancelSubmission) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navSuccess", nil) message:NSLocalizedString(@"collectionSuccessAreaDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
                [alert show];
            } else {
                cancelSubmission = NO;
                submissionFail = NO;
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        } else {
            cancelSubmission = NO;
            submissionFail = NO;
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorAreSubmit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
            [alert show];
        }
        [areasToSubmit removeAllObjects];
        
        uploadView.keepAlive = NO;
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self reloadAreas];
    }
}

- (void)notifyCollectionListener:(BOOL)fail observer:(id<Observer>)observer {
    [observer unregisterCollectionListener];
    submissionFail = fail;
}

- (IBAction)checkAllAreas:(id)sender {
    int currentTag = checkAllButton.tag;
    
    if (currentTag == 0) {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];

        for (Area *area in areas) {
            area.submitToServer = YES;
        }
        checkAllButton.tag = 1;
    } else {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox.png"]];
        for (Area *area in areas) {
            area.submitToServer = NO;
        }
        checkAllButton.tag = 0;
    }
    [table reloadData];
}
@end
