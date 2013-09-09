//
//  CollectionOverviewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionOverviewController.h"
#import "CheckboxCell.h"
#import "ObservationsOrganismSubmitController.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "AsyncRequestDelegate.h"
#import <QuartzCore/QuartzCore.h>

extern int UNKNOWN_ORGANISMGROUPID;
extern int UNKNOWN_ORGANISMID;

@implementation CollectionOverviewController
@synthesize observations, persistenceManager, observationsToSubmit, table, countObservations, queue, operationQueue, curIndex, doSubmit, checkAllButton, checkAllView, noEntryFoundLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        doSubmit = FALSE;
    }
    persistenceManager = [[PersistenceManager alloc] init];
    [table registerNib:[UINib nibWithNibName:@"CheckboxCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxCell"];
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"observationTabLabel", nil);
    self.navigationItem.title = title;
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"navSubmit", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(alertOnSendObservationsDialog)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:NSLocalizedString(@"navDel", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(removeObservations)];
    
    self.navigationItem.leftBarButtonItem = editButton;
    
    [checkAllButton setTag:1];
    
    noEntryFoundLabel.text = NSLocalizedString(@"noEntryFound", nil);
    
    // Reload the observations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    /*loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadObservations) onTarget:self withObject:nil animated:YES];*/
    
    // Reload table
    
    [table registerNib:[UINib nibWithNibName:@"CheckboxCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CheckboxCell"];
    [table reloadData];
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
- (void) alertOnSendObservationsDialog{
    doSubmit = TRUE;
    if(![self connectedToInternet]) {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertNoInternetTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertNoInternetDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)
                                                    otherButtonTitles:nil , nil];
        [submitAlert show];
    }
    else if([self connectedToWiFi]){
        [self sendObservations];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertObsTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertObsDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(doSubmit){
        if([alertView.title isEqualToString:NSLocalizedString(@"collectionAlertObsTitle", nil)]) {
            if (buttonIndex == 1){
                [self sendObservations];
            }

        }
        doSubmit = FALSE;
    }
}


- (IBAction)checkAllObs:(id)sender {
    int currentTag = checkAllButton.tag;
    
    if (currentTag == 0) {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];
        for (Observation *obs in observations) {
            obs.submitToServer = YES;
        }
        checkAllButton.tag = 1;
    } else {
        //[checkAllButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        [checkAllView setImage:[UIImage imageNamed:@"checkbox.png"]];
        for (Observation *obs in observations) {
            obs.submitToServer = NO;
        }
        checkAllButton.tag = 0;
    }
    
    [table reloadData];
}

- (void) sendObservations
{
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
    //new portal
    NSURL *url = [NSURL URLWithString:@"https://naturvielfalt.ch/webservice/api/observation"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    
    obsToSubmit = [[NSMutableArray alloc] init];
    for (Observation *ob in observations) {
        if (ob.submitToServer) {
            [obsToSubmit addObject:ob];
        }
    }
    requestCounter = obsToSubmit.count;
    totalRequests = requestCounter;
    
    if(requestCounter == 0) {
        //[loadingHUD removeFromSuperview];
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorObs", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    /*BOOL successfulTransmission = true;
     BOOL transmission_problem = false;*/
    
    requests = [[NSMutableArray alloc] init];
    asyncDelegates = [[NSMutableArray alloc] init];
    
    
    for(Observation *ob in obsToSubmit) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // Get username and password from the UserDefaults
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        
        NSString *username = [appSettings stringForKey:@"username"];
        NSString *password = [appSettings stringForKey:@"password"];
        
        if(username.length == 0 || password.length == 0) {
            [uploadView dismissWithClickedButtonIndex:0 animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorSettings", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setUsername:username];
        [request setPassword:password];
        [request setValidatesSecureCertificate: YES];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *dateString = [dateFormatter stringFromDate:ob.date];
        
        dateFormatter.dateFormat = @"HH:mm";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *timeString = [dateFormatter stringFromDate:ob.date];
        
        // Prepare data
        NSString *organism = [NSString stringWithFormat:@"%d", ob.organism.organismId];
        NSString *organismGroupId = [NSString stringWithFormat:@"%d", ob.organism.organismGroupId];
        NSString *count = [NSString stringWithFormat:@"%@", ob.amount];
        NSString *date = [NSString stringWithFormat:@"%@", dateString];
        NSString *time = [NSString stringWithFormat:@"%@", timeString];
        NSString *accuracy = [NSString stringWithFormat:@"%d", ob.accuracy];
        NSString *author = [NSString stringWithString:ob.author];
        NSString *longitude = [NSString stringWithFormat:@"%f", ob.location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f", ob.location.coordinate.latitude];
        NSString *comment = [NSString stringWithFormat:@"%@", ob.comment];
        
        // Upload image
        if([ob.pictures count] > 0) {
            for (ObservationImage *obsImg in ob.pictures) {
                // Create PNG image
                NSData *imageData = UIImagePNGRepresentation(obsImg.image);
                
                // And add the png image into the request
                [request addData:imageData withFileName:@"iphoneimage.png" andContentType:@"image/png" forKey:@"files[]"];
            }
        }
        [request setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"guid"];
        [request setPostValue:[NSString stringWithFormat:@"%d", 0] forKey:@"inventory_id"];
        [request setPostValue:organism forKey:@"organism_id"];
        [request setPostValue:organismGroupId forKey:@"organism_artgroup_id"];
        [request setPostValue:count forKey:@"count"];
        [request setPostValue:date forKey:@"date"];
        [request setPostValue:time forKey:@"time"];
        [request setPostValue:accuracy forKey:@"accuracy"];
        [request setPostValue:author forKey:@"observer"];
        [request setPostValue:longitude forKey:@"longitude"];
        [request setPostValue:latitude forKey:@"latitude"];
        [request setPostValue:comment forKey:@"comment"];
        
        [requests addObject:request];
        [self submitData:ob withRequest:request];
        //if(!successfulTransmission) transmission_problem = true;
    }
}

- (void) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request {
    
    AsyncRequestDelegate *asyncDelegate = [[AsyncRequestDelegate alloc] initWithObservation:ob];
    [asyncDelegate registerListener:self];
    request.delegate = asyncDelegate;
    [asyncDelegates addObject:asyncDelegate];
    
    [request startAsynchronous];
    
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void)beginLoadingObservations
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadObservations) object:nil];
    [operationQueue addOperation:operation];

}

- (void)synchronousLoadObservations
{
    NSMutableArray *arrNewObservations;
    @synchronized (self) {
        // Establish a connection
        [persistenceManager establishConnection];
        
        // Get all observations
        arrNewObservations = [persistenceManager getObservations];
        
        [persistenceManager closeConnection];
    }
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingObservations:) withObject:arrNewObservations waitUntilDone:YES];
}

- (void)didFinishLoadingObservations:(NSMutableArray *)arrNewObservations
{
    if(observations != nil){
        if([observations count] != [arrNewObservations count]){
            observations = arrNewObservations;
        }
    }
    else {
        observations = arrNewObservations;
    }
    
    countObservations = (int *)self.observations.count;
    
    if(table.editing)
       [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([observations count] < 1) {
        table.editing = NO;
        table.hidden = YES;
        noEntryFoundLabel.hidden = NO;
    } else {
        table.hidden = NO;
        noEntryFoundLabel.hidden = YES;
    }
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void) reloadObservations
{
    // Reset observations
    observations = nil;
    [self beginLoadingObservations];
}

- (void) viewWillAppear:(BOOL)animated 
{
    table.editing = NO;
    loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    loadingHUD.mode = MBProgressHUDModeCustomView;
    [self reloadObservations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        self.curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];

        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        [observations removeObjectAtIndex:indexPath.row];
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:curIndex] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([observations count] < 1) {
            table.editing = NO;
            table.hidden = YES;
            noEntryFoundLabel.hidden = NO;
        }
        
        // Reload the observations from the database and refresh the TableView
        //[self reloadObservations];
    }   
}


// MARK: -
// MARK: TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.observations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell" forIndexPath:indexPath];
    
    // use CustomCell layout 
    CheckboxCell *checkboxCell;
        
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxCell" owner:self options:nil];
        checkboxCell =  (CheckboxCell *)topLevelObjects[0];
    } else {
        checkboxCell = (CheckboxCell *)cell;
    }
            
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        
        if(observation.pictures.count > 0){
            UIImage *original = ((ObservationImage *)[observation.pictures objectAtIndex:0]).image;
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
            checkboxCell.image.image = final;
            NSLog(@"Image!: %@", [observation.organism getName]);
        }
        else {
            checkboxCell.image.image = [UIImage imageNamed:@"blank.png"];
        }
        
        if (observation.organism.organismId == UNKNOWN_ORGANISMID) {
            checkboxCell.name.text = NSLocalizedString(@"unknownOrganism", nil);
            checkboxCell.latName.text = NSLocalizedString(@"toBeDetermined", nil);
            checkboxCell.name.textColor = [UIColor grayColor];
            checkboxCell.latName.textColor = [UIColor grayColor];
        } else {
            checkboxCell.name.text = [observation.organism getName];
            checkboxCell.latName.text = [observation.organism getLatName];
            checkboxCell.name.textColor = [UIColor blackColor];
            checkboxCell.latName.textColor = [UIColor blackColor];
        }
        
        checkboxCell.date.text = nowString;
        checkboxCell.amount.text = observation.amount;
        
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.checkbox setTag:observation.observationId];

        // Define the action on the button and the current row index as tag
        [checkboxCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.remove setTag:observation.observationId];

        // Set checkbox icon
        if(observation.submitToServer) {
            //checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
            [checkboxCell.checkboxView setImage:[UIImage imageNamed:@"checkbox_checked.png"]];
        } else {
            //checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.png"];
            [checkboxCell.checkboxView setImage:[UIImage imageNamed:@"checkbox.png"]];
        }
    }
    checkboxCell.layer.shouldRasterize = YES;
    checkboxCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return checkboxCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Observation *ob in observations) {
        if(ob.observationId == [number longLongValue]) {
            ob.submitToServer = !ob.submitToServer;
        }
    }
    
    [table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                      initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    // Store the current observation object
    Observation *observationShared = [[Observation alloc] getObservation];
    [observationShared setObservation:observation];
    
    NSLog(@"Observation in CollectionOverView: %@", [observationShared getObservation]);
    
    // Set the current displayed organism
    organismSubmitController.observation = observation;
    organismSubmitController.organism = observation.organism;
    organismSubmitController.review = YES;
    organismSubmitController.organismGroup = observation.organismGroup;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
    organismSubmitController = nil;
}

# pragma Listener methods
- (void)notifyListener:(Observation *)observation response:(NSString *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    float percent = (100 / totalRequests) * (totalRequests - (--requestCounter));
    NSLog(@"requestcounter: %d progress: %f",requestCounter + 1,  percent / 100);
    uploadView.progressView.progress = percent / 100;
    
    //Save received guid in object, not persisted yet
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
    NSString *successString;
    if ([matches count] > 0) {
        successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
    } else {
        NSLog(@"ERROR: NO GUID received!! response: %@", response);
    }
    
    if ([successString isEqualToString:@"success=1"]) {
        // And Delete the observation form the database
        @synchronized (self) {
            [persistenceManager establishConnection];
            [persistenceManager deleteObservation:observation.observationId];
            [persistenceManager closeConnection];
        }
        // Reload observations
        [self reloadObservations];
        [obsToSubmit removeObject:observation];
    }
    
    if (requestCounter == 0) {
        for (AsyncRequestDelegate *asynDelegate in asyncDelegates) {
            [asynDelegate unregisterListener];
        }
        [asyncDelegates removeAllObjects];
        [requests removeAllObjects];
        
        if (obsToSubmit.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navSuccess", nil) message:NSLocalizedString(@"collectionSuccessObsDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil) otherButtonTitles:nil, nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"navError", nil) message:NSLocalizedString(@"collectionAlertErrorObsSubmit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navOk", nil)  otherButtonTitles:nil, nil];
            [alert show];
        }
        //[loadingHUD removeFromSuperview];
        [uploadView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)viewDidUnload {
    [self setCheckAllButton:nil];
    [self setCheckAllView:nil];
    [self setNoEntryFoundLabel:nil];
    [super viewDidUnload];
}
@end
