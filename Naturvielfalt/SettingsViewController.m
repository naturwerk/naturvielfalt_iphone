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
@synthesize tableView;

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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    
    titlesSectionOne = [[NSMutableArray alloc] init];
    
    [titlesSectionOne addObject:NSLocalizedString(@"settingsUsername", nil)];
    [titlesSectionOne addObject:NSLocalizedString(@"settingsPwd", nil)];
    [titlesSectionOne addObject:NSLocalizedString(@"settingsWikiImg", nil)];
    [titlesSectionOne addObject:NSLocalizedString(@"settingsWikiArt", nil)];
    
    /*titlesSectionTwo = [[NSMutableArray alloc] init];
    [titlesSectionTwo addObject:NSLocalizedString(@"settingsMap", nil)];*/
    
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"settingsNavTitle", nil);
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
        
        // Switch the View & Controller
        [self.navigationController pushViewController:settingsUsernameController animated:YES];
        settingsUsernameController = nil;
    } else if(indexPath.row == 1) {
        // Password
        // Create the ObservationsOrganismSubmitCameraController
        SettingsPasswordViewController *settingsPasswordController = [[SettingsPasswordViewController alloc] 
                                                                      initWithNibName:@"SettingsPasswordViewController" 
                                                                      bundle:[NSBundle mainBundle]];
        
        // Switch the View & Controller
        [self.navigationController pushViewController:settingsPasswordController animated:YES];
        settingsPasswordController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (indexPath.section == 0) {
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
        }
        
        cell.textLabel.text = [titlesSectionOne objectAtIndex:indexPath.row];
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
                // Store the username in the appSettings
                [appSettings setObject:username forKey:@"username"];
                [appSettings synchronize];
                cell.detailTextLabel.text = (username.length > 0) ? username : @"-";
            } else {
                
                NSString *password = @"";
                
                if([appSettings objectForKey:@"password"] != nil) {
                    password = [appSettings stringForKey:@"password"];
                }
                
                // Password
                // Store the username in the appSettings
                [appSettings setObject:password forKey:@"password"];
                [appSettings synchronize];
                cell.detailTextLabel.text = (password.length > 0) ? @"*********" : @"-";
            }
            
        } else {
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            
            cell.accessoryView = mySwitch;
            
            if(indexPath.row == 2) {
                
                if([appSettings objectForKey:@"showImages"] != nil) {
                    BOOL showImages = [[appSettings stringForKey:@"showImages"] isEqualToString:@"on"];
                    [(UISwitch *)cell.accessoryView setOn:showImages];
                }
                
            }
            if(indexPath.row == 3) {
                
                if([appSettings objectForKey:@"showWikipedia"] != nil) {
                    BOOL showWikipedia = [[appSettings stringForKey:@"showWikipedia"] isEqualToString:@"on"];
                    [(UISwitch *)cell.accessoryView setOn:showWikipedia];
                }
                
            }
            [(UISwitch *)cell.accessoryView addTarget:self action:@selector(mySelector:)
                                    forControlEvents:UIControlEventValueChanged];
        }
    } else {
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        /*NSArray *keys = [NSArray arrayWithObjects:NSLocalizedString(@"settingsMapSatellite", nil), NSLocalizedString(@"settingsMapHybrid", nil), NSLocalizedString(@"settingsMapStandard", nil), nil];
        segmentControl = [[UISegmentedControl alloc] initWithItems:keys];
        [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        segmentControl.frame = CGRectMake(10, 0, segmentControl.frame.size.width, segmentControl.frame.size.height);
        
        [segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        
         NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        int mapType = [[appSettings stringForKey:@"mapType"] integerValue];
        
        switch (mapType) {
            case 1:
            {
                [segmentControl setSelectedSegmentIndex:0];
                break;
            }
            case 2:
            {
                [segmentControl setSelectedSegmentIndex:1];
                break;
            }
            case 3:
            {
                [segmentControl setSelectedSegmentIndex:2];
                break;
            }
        }
        
        //[cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:0.0f]];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [cell addSubview:segmentControl];*/
    }
    return cell;
}

/*- (IBAction)segmentChanged:(id)sender {
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"satelite");
            [appSettings setObject:@"1" forKey:@"mapType"];
            break;
        }
        case 1:
        {
            NSLog(@"hybride");
            [appSettings setObject:@"2" forKey:@"mapType"];
            break;
        }
        case 2:
        {
            NSLog(@"map");
            [appSettings setObject:@"3" forKey:@"mapType"];
        }
    }
    [appSettings synchronize];
}*/

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
    if(indexPath.row == 3) {
        
        // Show images value
        [appSettings setObject:on forKey:@"showWikipedia"];
    }
    [appSettings synchronize];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (section == 0) {
        return [titlesSectionOne count];
    /*} else {
        return [titlesSectionTwo count];
    }*/
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /*if (section == 1) {
        return NSLocalizedString(@"settingsMap", nil);
    }*/
    return nil;
}

@end
