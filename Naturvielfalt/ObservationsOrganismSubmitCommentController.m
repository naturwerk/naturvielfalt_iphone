//
//  ObservationsOrganismSubmitCommentController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismSubmitCommentController.h"
#import "ObservationsOrganismSubmitController.h"

@implementation ObservationsOrganismSubmitCommentController
@synthesize textView;
@synthesize observation;

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
    NSString *title = [[NSString alloc] initWithString:@"Bemerkung"];
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Speichern"
                                                           style:UIBarButtonItemStylePlain 
                                                           target:self 
                                                           action:@selector(saveComment)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    // Get Observation object
    Observation *observation = [[Observation alloc] getObservation];
    
    // Load the current observation comment into the textview
    textView.text = observation.comment;
}

- (void) saveComment
{
    // Save the comment
    observation.comment = textView.text;
    

    // Change view back to submitController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                      initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Set the current displayed organism
    organismSubmitController.organism = observation.organism;
    
    // Switch the View & Controller
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
    [organismSubmitController release];
    organismSubmitController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // textView = nil;
}

- (void) dealloc
{
    [super dealloc];
    
    // [textView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end