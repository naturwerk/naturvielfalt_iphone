//
//  ObservationsViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsViewController.h"
#import "ObservationsOrganismViewController.h"
#import "ObservationsOrganismFilterViewController.h"
#import "SBJson.h"
#import "OrganismGroup.h"
#import "SwissCoordinates.h"
#import "Settings.h"
#import "InfoController.h"
#import "PersistenceManager.h"
#import "ObservationsOrganismSubmitController.h"

@implementation ObservationsViewController
@synthesize listData, table, spinner, groupId, classlevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Root element has the id 3
        groupId = 3;
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
    // Parse the JSON from the Naturvielfalt Webservice (Get all organism groups)
    [self loadFromWebsite];
    
    // NSMutableArray *organisms = [persistenceManager getAllOrganisms:31];
     

    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Filter"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(changeToFilterView)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    [filterButton release];
    
    
    // Check if its the root element. Otherwise don't display the INFO Page
    // Because we need the back button to get back to the overview page
    if(groupId == 3) {
        // Set info button
        UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(infoPage) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        
        [self.navigationItem setLeftBarButtonItem:modalButton animated:YES];
        [modalButton release];
    }
    
    // Set the title of the Navigationbar
    NSString *title = [[NSString alloc] initWithString:@"Naturvielfalt"];
    self.navigationItem.title = title;
    
    [title release];
    
    // Reload the table data
    [table reloadData];
    
    // Spinner shouldnt spin at startup
    [spinner stopAnimating];
    
    // Call super view did load
    [super viewDidLoad];
}

- (void) infoPage
{
    
    NSLog(@"INFO PAGE");
    
    // Create the ObservationsOrganismViewController
    InfoController *infoController = [[InfoController alloc] 
                                                              initWithNibName:@"InfoController" 
                                                              bundle:[NSBundle mainBundle]];

    [self.navigationController pushViewController:infoController animated:TRUE];
    
    [infoController release];
    infoController = nil;

}

- (void) changeToFilterView 
{
    // Create the ObservationsOrganismViewController
    ObservationsOrganismFilterViewController *organismFilterController = [[ObservationsOrganismFilterViewController alloc] 
                                                                    initWithNibName:@"ObservationsOrganismFilterViewController" 
                                                                    bundle:[NSBundle mainBundle]];
        
    // Switch the View & Controller
    [self.navigationController pushViewController:organismFilterController animated:TRUE];
    
    [organismFilterController release];
}

-(void) viewDidAppear:(BOOL)animated {
    
    [table reloadData];
}

- (void)dealloc
{
    [super dealloc];
    
    /*
    [listData release];
    [spinner release];
    [table release];
     */
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    /*
    self.listData = nil;
    self.spinner = nil;
    self.table = nil;
    */
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
  return [self.listData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier] autorelease];
    }
    
    // Set title
    NSInteger row = [indexPath row];
    
    // display an image at every row
    UIImage *icon = [UIImage imageNamed:@"12-eye.png"];
    cell.imageView.image = icon;
    
    OrganismGroup *organismGroup = [listData objectAtIndex:row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    cell.textLabel.text = organismGroup.name;
    
    // Set detail label
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Arten", organismGroup.count];;
    
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
    
    // Get all organismGroups
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    
    NSLog(@"BEFORE");
    // NSMutableArray *groups = [persistenceManager getAllOrganismGroups:currentSelectedOrganismGroup.organismGroupId withClasslevel:classlevel];
    NSLog(@"AFTER");    
    
    if([persistenceManager organismGroupHasChild:currentSelectedOrganismGroup.organismGroupId]) {
        overviewController.groupId = currentSelectedOrganismGroup.organismGroupId;
        overviewController.classlevel = classlevel + 1;
        
        [self.navigationController pushViewController:overviewController animated:TRUE];
    } else {
        
        
        if(currentSelectedOrganismGroup.organismGroupId == 1000) {
            // Then its a not yet defined organism
            // Create the ObservationsOrganismViewController
            ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                              initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                              bundle:[NSBundle mainBundle]];
            
            Organism *notYetDefinedOrganism = [[Organism alloc] init];
            notYetDefinedOrganism.nameDe = @"Noch nicht bestimmt";
            notYetDefinedOrganism.organismGroupId = currentSelectedOrganismGroup.organismGroupId;
            
            // Set the current displayed organism
            organismSubmitController.organism = notYetDefinedOrganism;
            organismSubmitController.review = false;
            
            // Switch the View & Controller
            [self.navigationController pushViewController:organismSubmitController animated:TRUE];
            [organismSubmitController release];
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
        
        [organismController release];
        organismController = nil;
    }


}


-(void) loadFromWebsite 
{
    
    // Get all oranismGroups
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    
    // Get all Root elements (Root elements have the id 3)
    NSLog(@"groupid: %d, classlevel: %d", groupId, classlevel);
    self.listData = [persistenceManager getAllOrganismGroups:groupId withClasslevel:classlevel];
    
    OrganismGroup *notDefinedOrganismGroup = [[OrganismGroup alloc] init];
    notDefinedOrganismGroup.organismGroupId = 1000;
    notDefinedOrganismGroup.name = @"Nicht identifizert";
    
    [self.listData addObject:notDefinedOrganismGroup];
    
    /*
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // JSON Request url
    NSURLRequest *request;
    
    NSString *model = [[UIDevice currentDevice] model];
    
    Settings *settings = [[Settings alloc] getSettings];
    
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://devel.naturvielfalt.ch/api/organisms/"]];
    // request = [NSURLRequest requestWithURL:[NSURL URLWithString:settings.urlWebservice]];
    
    // request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/swissmon/application/api/organismgroups/"]];
    
    // Start activities (Displaying that the application is doing something)
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = true;
    
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSArray *organismObject = [parser objectWithString:json_string error:nil];

    // initialize array
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // Iterate over all organism groups
    for(NSDictionary *dict in organismObject) {
        NSInteger organismGroupId = [[dict objectForKey:@"inventory_type_id"] intValue];
        NSString *name = [dict objectForKey:@"name"];
        NSInteger count = [[dict objectForKey:@"count"] intValue];
        
        // create an organismgroup and fill it with the corresponding data
        OrganismGroup *organismGroup = [[OrganismGroup alloc] init];
        
        organismGroup.organismGroupId = organismGroupId;
        organismGroup.name = name;
        organismGroup.count = count;

        // add the created organism group
        [array addObject:organismGroup];
        
        [organismGroup release];
    }
    
    self.listData = array;
    [array release];
    
    // Stop activities
    app.networkActivityIndicatorVisible = false;
    
    [table reloadData];
     */
}

- (void) threadStartAnimating:(id)data {
    [spinner startAnimating];
}

@end
