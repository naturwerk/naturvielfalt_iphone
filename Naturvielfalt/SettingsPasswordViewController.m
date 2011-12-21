//
//  SettingsPasswordViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsPasswordViewController.h"
#import "SettingsViewController.h"

@implementation SettingsPasswordViewController
@synthesize textView, password;

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
    NSString *title = [[NSString alloc] initWithString:@"Passwort"];
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Speichern"
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(savePassword)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *password = @"";
    
    if([appSettings objectForKey:@"password"] != nil) {
        password = [appSettings stringForKey:@"password"];
    }
    
    textView.text = password;
}

- (void) savePassword {
    // Change view back to submitController
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] 
                                                                      initWithNibName:@"SettingsViewController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Store the username in the appSettings
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setObject:textView.text forKey:@"password"];
    [appSettings synchronize];
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:settingsViewController animated:TRUE];
    [settingsViewController release];
    settingsViewController = nil;
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
