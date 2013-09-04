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
@synthesize tv;

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
    [titlesSectionOne addObject:NSLocalizedString(@"settingsAccountInfo", nil)];
    [titlesSectionOne addObject:NSLocalizedString(@"settingsVisitHomepage", nil)];

    
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
    [tv reloadData];
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
    else if(indexPath.row == 3) {
        // Link to naturvielfalt.ch
        // Create the ObservationsOrganismSubmitCameraController
        NSURL *url = [ [ NSURL alloc ] initWithString: @"http://naturvielfalt.ch" ];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    UITableViewCell *infoCell = [tv dequeueReusableCellWithIdentifier:@"test"];
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
                }
                
                cell.textLabel.text = [titlesSectionOne objectAtIndex:indexPath.row];
                
                
                //if(indexPath.row < 2) {
                // Set detail label
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
                NSString *username = @"";
                
                if([appSettings objectForKey:@"username"] != nil) {
                    username = [appSettings stringForKey:@"username"];
                }
                
                // Username
                // Store the username in the appSettings
                [appSettings setObject:username forKey:@"username"];
                [appSettings synchronize];
                cell.detailTextLabel.text = (username.length > 0) ? username : @"-";
                return  cell;
            }
                break;
                
            case 1: {
                
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
                }
                
                cell.textLabel.text = [titlesSectionOne objectAtIndex:indexPath.row];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
                NSString *password = @"";
                
                if([appSettings objectForKey:@"password"] != nil) {
                    password = [appSettings stringForKey:@"password"];
                }
                
                // Password
                // Store the username in the appSettings
                [appSettings setObject:password forKey:@"password"];
                [appSettings synchronize];
                cell.detailTextLabel.text = (password.length > 0) ? @"*********" : @"-";
                return cell;
            }
                break;
                
            case 2: {
                if(infoCell == nil) {
                    infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
                }
                infoCell.textLabel.text = [titlesSectionOne objectAtIndex:indexPath.row];
                infoCell.userInteractionEnabled = NO;
                infoCell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                infoCell.textLabel.textColor = [UIColor lightGrayColor];
                infoCell.textLabel.font = [UIFont italicSystemFontOfSize:14.0];
                infoCell.textLabel.numberOfLines = 8;
                
                return infoCell;
            }
                break;
                
            case 3: {
                if(infoCell == nil) {
                    infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
                }
                infoCell.textLabel.text = [titlesSectionOne objectAtIndex:indexPath.row];
                infoCell.userInteractionEnabled = YES;
                infoCell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                infoCell.textLabel.textColor = [UIColor blueColor];
                infoCell.textLabel.font = [UIFont italicSystemFontOfSize:14.0];
                return infoCell;

                
                
            }
                break;

        }
        
        /*} else {
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
         
         NSArray *keys = [NSArray arrayWithObjects:NSLocalizedString(@"settingsMapSatellite", nil), NSLocalizedString(@"settingsMapHybrid", nil), NSLocalizedString(@"settingsMapStandard", nil), nil];
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*NSString * text = [titlesSectionOne objectAtIndex:indexPath.row];
     CGSize testSize = CGSizeMake(tableView.frame.size.width, tableView.frame.size.height - 50);
     CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize: 14.0] forWidth:[tableView frame].size.width - 40.0 lineBreakMode:UILineBreakModeWordWrap];
     // return either default height or height to fit the text
     CGFloat res = textSize.height < 44.0 ? 44.0 : textSize.height;
     NSLog(@"heightForRowAtIndexPath: textSize.height - %f float - %f", textSize.height, res);
     return testSize.height < 44.0 ? 44.0 : textSize.height;*/
    if (indexPath.row == 2) {
        return 140.0;
    }
    return 44.0;
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

/*- (void) mySelector:(id)sender {
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
 }*/

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
