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

@implementation CollectionOverviewController
@synthesize observations, persistenceManager, observationsToSubmit, table, countObservations, queue, progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
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
    NSString *title = [[NSString alloc] initWithString:@"Erfassungen"];
    self.navigationItem.title = title;
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Übermitteln"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(sendObservations)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Löschen"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(removeObservations)];
    
    self.navigationItem.leftBarButtonItem = editButton;
    
    // Reload the observations
    [self reloadObservations];
    
    // Reload table
    [table reloadData];
}

- (void) sendObservations
{
    MBProgressHUD *loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = @"Loading";
    loadingHUD.detailsLabelText = @"Daten werden übermittelt..";
    
    [loadingHUD showWhileExecuting:@selector(sendRequestToServer) onTarget:self withObject:nil animated:YES];
}

- (void) sendRequestToServer 
{
    NSURL *url = [NSURL URLWithString:@"http://devel.naturvielfalt.ch/webservice/submitData.php"];
    
    // OR for local testing
    // NSURL *url = [NSURL URLWithString:@"http://localhost/swissmon/application/webservice/submitData.php"];
    
    
    int counter = 0;
    for(Observation *ob in observations) {
        if(ob.submitToServer)
            counter++;
    }
    
    int i = 1;

    if(counter == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Es wurden noch keine Beobachtungen gespeichert." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }

    
    BOOL successfulTransmission = true;
    
    for(Observation *ob in observations) {
        if(ob.submitToServer) {
            
            // NSLog(@"SUBMIT: %@", [ob.organism getNameDe]);
            
            NSString *text = [NSString stringWithFormat:@"Transferring %@", [ob.organism getNameDe]];
            float currProgress = (float)(counter/i);

            // Get username and password from the UserDefaults
            NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
            
            NSString *username = [NSString stringWithString:@""];             
            NSString *password = [NSString stringWithString:@""];
            
            BOOL credentialsSetted = true;
            
            if([appSettings objectForKey:@"username"] != nil) {
                username = [appSettings stringForKey:@"username"];
            } else {
                credentialsSetted = false;
            }
            
            if([appSettings objectForKey:@"password"] != nil) {
                password = [appSettings stringForKey:@"password"];
            } else {
                credentialsSetted = false;
            }
            
            if(!credentialsSetted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Benutzername/Passwort wurde noch nicht gesetzt. Dies kann in den Einstellungen gesetzt werden." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [alert release]; 
                
                return;
            }
            
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setUsername:username];
            [request setPassword:password];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy";
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            NSString *dateString = [dateFormatter stringFromDate:ob.date];
            [dateFormatter release];
            
            // Prepare data
            NSString *organism = [NSString stringWithFormat:@"%d", ob.organism.organismId];
            NSString *organismGroupId = [NSString stringWithFormat:@"%d", ob.organism.organismGroupId];
            NSString *count = [NSString stringWithFormat:@"%@", ob.amount];
            NSString *date = [NSString stringWithFormat:@"%@", dateString];
            NSString *accuracy = [NSString stringWithFormat:@"%d", ob.accuracy];
            NSString *author = [NSString stringWithString:username];
            NSString *longitude = [NSString stringWithFormat:@"%f", ob.location.coordinate.longitude];
            NSString *latitude = [NSString stringWithFormat:@"%f", ob.location.coordinate.latitude];
            // NSString *comment = [NSString stringWithFormat:@"%@", ob.comment];
            
            // Upload image
            if([ob.pictures count] > 0) {
                
                // Creare PNG image
                NSData *imageData = UIImagePNGRepresentation([ob.pictures objectAtIndex:0]);
                
                // And add the png image into the request
                [request addData:imageData withFileName:@"iphoneimage.png" andContentType:@"image/png" forKey:@"file"];
            }
                
            [request setPostValue:organism forKey:@"organism"];
            [request setPostValue:organismGroupId forKey:@"type"];
            [request setPostValue:count forKey:@"count"];
            [request setPostValue:date forKey:@"date"];
            [request setPostValue:accuracy forKey:@"accuracy"];
            [request setPostValue:author forKey:@"author"];
            [request setPostValue:longitude forKey:@"longitude"];
            [request setPostValue:latitude forKey:@"latitude"];
            // [request setPostValue:comment forKey:@"comment"];

            successfulTransmission = [self submitData:ob withRequest:request withPersistenceManager:persistenceManager];
        }
        
        i++;
    } 
    
    if(successfulTransmission) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erfolgreich" message:@"Beobachtungen wurden erfolgreich übertragen." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Beobachtungen wurden leider NICHT erfolgreich übertragen. Bitte überprüfen Sie die Einstellungen." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];    }
}

- (BOOL) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request withPersistenceManager:(PersistenceManager *)persistenceManager {
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        
        // NSLog(@"Response: '%@'", response);
        
        if([response isEqualToString:@"SUCCESS"]) {
        
            // And Delete the observation form the database
            // PersistenceManager create
            persistenceManager = [[PersistenceManager alloc] init];
            
            // Establish a connection
            [persistenceManager establishConnection];
            
            // Delete submitted observation
            [persistenceManager deleteObservation:ob.observationId];
            
            // Reload observations
            observations = [persistenceManager getObservations];
            
            // Reload the table
            [table reloadData];
            
            // Close connection
            [persistenceManager closeConnection];   
        }
        
        return true;
    } else {        
        return false;
    }
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void) reloadObservations
{
    // Reset observations
    observations = nil;
    
    // PersistenceManager create
    persistenceManager = [[PersistenceManager alloc] init];
    
    // Establish a connection
    [persistenceManager establishConnection];
    
    // Get all observations
    observations = [persistenceManager getObservations];
    
    countObservations = (int *)self.observations.count;
    
    // Close the connection
    [persistenceManager closeConnection];
}

- (void) viewWillAppear:(BOOL)animated 
{
    // PersistenceManager create
    persistenceManager = [[PersistenceManager alloc] init];
    
    // Establish a connection
    [persistenceManager establishConnection];
    
    // Update the observation array    
    if([persistenceManager getObservations].count != observations.count) {    
       [self reloadObservations]; 
    }
     
    // Close the connection
    [persistenceManager closeConnection];
    
    [table reloadData];
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
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];

        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        // Reload the observations from the database and refresh the TableView
        [self reloadObservations];
        
        // If there aren't any observations in the list. Stop the editing mode.
        if(observations.count < 1) {
            tableView.editing = false;
        }
        
        // delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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
    static NSString *cellIdentifier = @"CheckboxCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout 
    CheckboxCell *checkboxCell;
        
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxCell =  (CheckboxCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxCell = (CheckboxCell *)cell;
    }
            
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        [dateFormatter release];
        
        checkboxCell.name.text = [observation.organism getNameDe];
        checkboxCell.date.text = nowString;
        checkboxCell.amount.text = observation.amount;
        checkboxCell.latName.text = [observation.organism getLatName];
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.checkbox setTag:observation.observationId];

        // Define the action on the button and the current row index as tag
        [checkboxCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.remove setTag:observation.observationId];

        // Set checkbox icon
        if(observation.submitToServer) {
            checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }
    }
    
    return checkboxCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Observation *ob in observations) {
        if(ob.observationId == [number intValue]) {
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
    organismSubmitController.organism = observation.organism;
    organismSubmitController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
    [organismSubmitController release];
    organismSubmitController = nil;
}


@end
