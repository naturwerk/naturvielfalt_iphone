//
//  ObservationsOrganismDetailViewWikipediaController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismDetailViewWikipediaController.h"
#import "ObservationsOrganismSubmitController.h"
#import "WikipediaHelper.h"

@implementation ObservationsOrganismDetailViewWikipediaController
@synthesize webView, latName, organism;

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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [super viewDidLoad];
    
    // Set top navigation bar button
    UIImage *submitImage = [UIImage imageNamed:@"12-eye-white.png"];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithImage: submitImage
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(submitObservation)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithString:@"Wikipedia"];
    self.navigationItem.title = title;
    
    // Load wikipedia html source code
    WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
    NSString *formatedHtmlSrc = [wikipediaHelper getWikipediaHTMLPage:latName];
    [webView loadHTMLString:formatedHtmlSrc baseURL:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
     
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) submitObservation
{
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                      initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Set the current displayed organism
    organismSubmitController.organism = organism;
    organismSubmitController.review = false;
    organismSubmitController.comeFromOrganism = true;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
    organismSubmitController = nil;
}

@end
