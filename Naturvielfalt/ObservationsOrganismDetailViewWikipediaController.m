//
//  ObservationsOrganismDetailViewWikipediaController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismDetailViewWikipediaController.h"
#import "WikipediaHelper.h";

@implementation ObservationsOrganismDetailViewWikipediaController
@synthesize webView, latName;

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
    NSString *title = [[NSString alloc] initWithString:@"Wikipedia"];
    self.navigationItem.title = title;
    
    // Load wikipedia html source code
    WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
    NSString *formatedHtmlSrc = [wikipediaHelper getWikipediaHTMLPage:latName];
    [webView loadHTMLString:formatedHtmlSrc baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
