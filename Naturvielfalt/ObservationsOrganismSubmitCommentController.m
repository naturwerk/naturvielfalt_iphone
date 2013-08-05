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
@synthesize textView, observation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    NSString *title = NSLocalizedString(@"observationDescr", nil);
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                           style:UIBarButtonItemStylePlain 
                                                           target:self 
                                                           action:@selector(saveComment)];
    
    self.navigationItem.rightBarButtonItem = backButton;
    
    // Load the current observation comment into the textview
    textView.text = observation.comment;
}

- (void) saveComment
{
    // Save the comment
    observation.comment = textView.text;
    
    if (observation.inventory) {
        observation.submitted = NO;
    }
    
    [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];

    
    // POP
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // textView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end