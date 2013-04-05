//
//  InfoController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoController.h"

@implementation InfoController
@synthesize lblPartner;
@synthesize scrollView;
@synthesize infoText;

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
    NSString *title = @"Naturvielfalt";
    self.navigationItem.title = title;
    
    infoText.text = @"Naturvielfalt (www.naturvielfalt.ch) bietet ein vielseitiges Informations- und Erfassungsportal für Flora und Fauna in der Schweiz und Umgebung.\nErstellen Sie ein Konto um Beobachtungen zu erfassen und verwalten.\n\nDieses App wurde vom Verein Naturwerk (www.naturwerk.info) aus Brugg entwickelt.\nDer Verein für Mensch, Natur und Arbeit übernimmt gemeinnützige Aufgaben im Bereich Umwelt-, Natur- und Artenschutz, die von öffentlichem Interesse sind.\n\nDurch die Unterstützung dieser App fördern Sie praktische Artenschutzprojekte sowie die Weiterentwicklung der Applikation.\n\nBei Feedback oder für technischen Support wenden Sie sich bitte an info@naturvielfalt.ch.\n\n© 2012 Naturwerk";
    CGRect infoFrame;
    infoFrame = infoText.frame;
    infoFrame.size.height = [infoText contentSize].height + 20;
    infoText.frame = infoFrame;
    infoText.showsVerticalScrollIndicator = NO;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, [infoText contentSize].height + 50);
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
