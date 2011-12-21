//
//  CollectionViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionRootController.h"

@implementation CollectionRootController
@synthesize collectionOverview;

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

    // Do any additional setup after loading the view from its nib.
    if ([self.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    // Create the ObservationsOrganismViewController
    CollectionOverviewController *viewController = [[CollectionOverviewController alloc] 
                                                  initWithNibName:@"CollectionOverviewController" 
                                                  bundle:[NSBundle mainBundle]];
    
    // Load first Observations view controller
    [self pushViewController:viewController animated:YES];
    
    [viewController release];
    viewController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    collectionOverview = nil;
}

- (void) dealloc
{
    [super dealloc];
    
    [collectionOverview release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
