//
//  InfoController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoController.h"

@implementation InfoController
@synthesize lblPartner, scrollView, infoText, aboutUsLabel;

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
    NSString *title = NSLocalizedString(@"infoNavTitle", nil);
    self.navigationItem.title = title;
    
    aboutUsLabel.text = NSLocalizedString(@"infoTitle", nil);
    
    infoText.text = NSLocalizedString(@"infoText", nil);
    CGRect infoFrame;
    infoFrame = infoText.frame;
    infoFrame.size.height = [infoText contentSize].height + 20;
    infoText.frame = infoFrame;
    infoText.showsVerticalScrollIndicator = NO;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, [infoText contentSize].height + 50);
}

- (void)viewDidUnload
{
    [self setAboutUsLabel:nil];
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
