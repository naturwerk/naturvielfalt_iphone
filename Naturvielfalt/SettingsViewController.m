//
//  SettingsViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsUsernameViewController.h"
#import "SettingsPasswordViewController.h"



@implementation SettingsViewController
@synthesize tableView, titles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    
    titles = [[NSMutableArray alloc] init];
    
    [titles addObject:@"Benutzername"];
    [titles addObject:@"Passwort"];
    [titles addObject:@"Bilder Vorschau"];
    
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = [[NSString alloc] initWithString:@"Einstellungen"];
    self.navigationItem.title = title;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        // Username
        // Create the ObservationsOrganismSubmitCameraController
        SettingsUsernameViewController *settingsUsernameController = [[SettingsUsernameViewController alloc] 
                                                                                      initWithNibName:@"SettingsUsernameViewController" 
                                                                                      bundle:[NSBundle mainBundle]];
        
        
        // settingsUsernameController.username = ;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:settingsUsernameController animated:TRUE];
        [settingsUsernameController release];
        settingsUsernameController = nil;
    } else if(indexPath.row == 1) {
        // Password
        // Create the ObservationsOrganismSubmitCameraController
        SettingsPasswordViewController *settingsPasswordController = [[SettingsPasswordViewController alloc] 
                                                                      initWithNibName:@"SettingsPasswordViewController" 
                                                                      bundle:[NSBundle mainBundle]];
        
        
        // settingsUsernameController.username = ;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:settingsPasswordController animated:TRUE];
        [settingsPasswordController release];
        settingsPasswordController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier] autorelease];
    }
    
    
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    
     NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    if(indexPath.row < 2) {
        // Set detail label
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];

        if(indexPath.row == 0) {
            
            NSString *username = @"";
            
            if([appSettings objectForKey:@"username"] != nil) {
                username = [appSettings stringForKey:@"username"];
            }
              
            // Username
            cell.detailTextLabel.text = (username.length > 0) ? username : @"-";
        } else {
            
            NSString *password = @"";
            
            if([appSettings objectForKey:@"password"] != nil) {
                password = [appSettings stringForKey:@"password"];
            }
             
            // Password
            cell.detailTextLabel.text = (password.length > 0) ? @"*********" : @"-";
        }
        
    } else {
        UISwitch *mySwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        
        cell.accessoryView = mySwitch;
        
        if(indexPath.row == 2) {
            
            if([appSettings objectForKey:@"showImages"] != nil) {
                BOOL showImages = [[appSettings stringForKey:@"showImages"] isEqualToString:@"on"];
                [(UISwitch *)cell.accessoryView setOn:showImages]; 
            }
            
        }
        
        
        [(UISwitch *)cell.accessoryView addTarget:self action:@selector(mySelector:)
                                 forControlEvents:UIControlEventValueChanged];
    }

    return cell;
}

- (void) mySelector:(id)sender {
    // Cast the sender as a UISwitch
    UISwitch *aSwitch = (UISwitch *)sender;
    
    // Cast the superview of aSwitch to a UITableViewCell
    UITableViewCell *cell = (UITableViewCell *)aSwitch.superview;
    
    // You could get an indexPath as follows (though you don't need it in this case)
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];    
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];

    NSString *on = (aSwitch.on) ? @"on" : @"off";
    
    if(indexPath.row == 2) {

        // Show images value
        [appSettings setObject:on forKey:@"showImages"];
    }
    
    [appSettings synchronize];
    
    // Set the text of the label in your cell
    // NSLog(aSwitch.on ? @"Active" : @"Disabled");
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [titles count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
