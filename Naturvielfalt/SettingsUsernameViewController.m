//
//  SettingsUsernameViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsUsernameViewController.h"
#import "SettingsViewController.h"

@implementation SettingsUsernameViewController
@synthesize textView, username;

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
    [super viewDidLoad];

    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"settingsUsername", nil);
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(saveUsername)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    if([appSettings objectForKey:@"username"] != nil) {
        username = [appSettings stringForKey:@"username"];
    } else {
        username = @"";
    }    
    
    textView.text = username;
}

- (void) saveUsername {
    // Store the username in the appSettings
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setObject:textView.text forKey:@"username"];
    [appSettings synchronize];
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
