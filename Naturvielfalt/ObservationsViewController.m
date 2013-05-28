//
//  ObservationsViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsViewController.h"
#import "ObservationsOrganismViewController.h"
#import "OrganismGroup.h"
#import "SwissCoordinates.h"
#import "InfoController.h"
#import "PersistenceManager.h"
#import "ObservationsOrganismSubmitController.h"

@implementation ObservationsViewController
@synthesize listData, table, spinner, groupId, classlevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Root element has the id 1
        groupId = 1;
        classlevel = 1;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Load the organism from the db
    [self loadOrganismusGroups];
    
    // Check if its the root element. Otherwise don't display the INFO Page
    // Because we need the back button to get back to the overview page
    if(groupId == 1) {
        // Set info button
        UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(infoPage) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        
        [self.navigationItem setLeftBarButtonItem:modalButton animated:YES];
    }
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"naturNavTitle", nil);
    self.navigationItem.title = title;
    
    
    // Reload the table data
    [table reloadData];
    
    // Spinner shouldnt spin at startup
    [spinner stopAnimating];
    
    // Call super view did load
    [super viewDidLoad];
}

- (void) infoPage
{
    // Create the ObservationsOrganismViewController
    InfoController *infoController = [[InfoController alloc] 
                                                              initWithNibName:@"InfoController" 
                                                              bundle:[NSBundle mainBundle]];

    [self.navigationController pushViewController:infoController animated:TRUE];
    
    infoController = nil;

}

-(void) viewDidAppear:(BOOL)animated {
    
    [table reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
  return [self.listData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    //static NSString *cautionIconIdentifier = @"CautionIconIdentifier";
    
    UITableViewCell *cell;
    
    NSInteger row = [indexPath row];
    OrganismGroup *organismGroup = [listData objectAtIndex:row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    // display an image at every row
    UIImage *icon = [UIImage imageNamed:@"12-eye.png"];
    cell.imageView.image = icon;
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    cell.textLabel.text = organismGroup.name;
    
    // Set detail label
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    NSString *detailTextLabel;
    
    if(organismGroup.count == 0) {
        detailTextLabel = @"→";
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    } else {
        //changing icons for custom artgroups
        if (organismGroup.organismGroupId == 29) {
            cell.imageView.image = [UIImage imageNamed:@"15-warning.png"];
        }
        detailTextLabel = [NSString stringWithFormat:@"%d %@", organismGroup.count, NSLocalizedString(@"naturSpecies", nil)];
    }
    
    cell.detailTextLabel.text = detailTextLabel;
    
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get the selected row
    OrganismGroup *currentSelectedOrganismGroup = [listData objectAtIndex:indexPath.row];
    
    // Create the ObservationsOrganismViewController
    ObservationsOrganismViewController *organismController = [[ObservationsOrganismViewController alloc] 
                                                              initWithNibName:@"ObservationsOrganismViewController" 
                                                              bundle:[NSBundle mainBundle]];
    
    // Create the ObservationsOrganismViewController
    ObservationsViewController *overviewController = [[ObservationsViewController alloc] 
                                                              initWithNibName:@"ObservationsViewController" 
                                                              bundle:[NSBundle mainBundle]];
    
    // set the organismGroupId so it know which inventory is selected
    organismController.organismGroupId = currentSelectedOrganismGroup.organismGroupId;
    organismController.organismGroupName = currentSelectedOrganismGroup.name;
    
    // Find out if this organism group has at least one child
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    BOOL hasChild = [persistenceManager organismGroupHasChild:currentSelectedOrganismGroup.organismGroupId];
    [persistenceManager closeConnection];
    
    // If the organismGroup has subgroups call again OverviewController
    if( hasChild && currentSelectedOrganismGroup.organismGroupId != 1) {
        overviewController.groupId = currentSelectedOrganismGroup.organismGroupId;
        overviewController.classlevel = classlevel + 1;
        [self.navigationController pushViewController:overviewController animated:TRUE];
        overviewController = nil;
        
    } else {
        // If the OrganismGroup does not have any subgroups 
        // directly go to the detail page of an organism
        
        if(currentSelectedOrganismGroup.organismGroupId == 1000) {
            // Then its a not yet defined organism
            // Create the ObservationsOrganismViewController
            ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                              initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                              bundle:[NSBundle mainBundle]];
            
            Organism *notYetDefinedOrganism = [[Organism alloc] init];
            notYetDefinedOrganism.nameDe = NSLocalizedString(@"naturNotDefinedOrganism", nil);
            notYetDefinedOrganism.organismGroupId = currentSelectedOrganismGroup.organismGroupId;
            
            // Set the current displayed organism
            organismSubmitController.organism = notYetDefinedOrganism;
            organismSubmitController.review = false;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitController animated:TRUE];
            organismSubmitController = nil;
            
            return;
        }
        
        
        // Start the spinner
        [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
        
        // Switch the View & Controller 
        // (Also load all the organism from the organism group in the ViewDidLoad from ObsvervationsOrganismViewController)
        [self.navigationController pushViewController:organismController animated:TRUE];
        
        // Stop the spinner
        [spinner stopAnimating];
        
        organismController = nil;
        
    }
}


-(void) loadOrganismusGroups 
{
    
    // Get all oranismGroups
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    
    // Get all Root elements (Root elements have the id 1)
    self.listData = [persistenceManager getAllOrganismGroups:groupId withClasslevel:classlevel];
    
    [persistenceManager closeConnection];
}

- (void) threadStartAnimating:(id)data {
    [spinner startAnimating];
}

@end
