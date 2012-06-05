//
//  ObservationsOrganismDetailViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 12.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismDetailViewController.h"
#import "ObservationsOrganismSubmitController.h"
#import "ObservationsOrganismDetailViewWikipediaController.h"
#import "OrganismFauna.h"
#import "OrganismFlora.h"
#import "WikipediaHelper.h"

@implementation ObservationsOrganismDetailViewController
@synthesize organism, nameDe, nameLat, family, keyOne, keyTwo, valueOne, valueTwo, wikiButton, picture, imageAuthor;

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
    
    // Set top navigation bar button
    UIImage *submitImage = [UIImage imageNamed:@"12-eye-white.png"];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                      initWithImage: submitImage
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(submitObservation)];
                                    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set navigation bar title
    self.navigationItem.title = @"Details";
    
    nameDe.text = [organism getNameDe];
    nameLat.text = [organism getLatName];
    family.text = organism.family;
    
    /*
     Additional fields are disabled because of the new database..
     
    if(organism.organismGroupId == 16) {
        // Flora
        OrganismFlora *organismFlora = (OrganismFlora *)organism;
        
        keyOne.text = @"";
        valueOne.text = @"";

        keyTwo.text = @"";
        valueTwo.text = @"";
    } else {
        // Fauna
        OrganismFauna *organismFauna = (OrganismFauna *)organism;
        
        keyOne.text = @"Geschützt in der Schweiz:";
        valueOne.text = (organismFauna.protectionCH) ? @"Ja" : @"Nein";
        
        keyTwo.text = @"Rote Liste: ";
        valueTwo.text = @"Ja / Nein";
    }
    */
    
    NSString *latName = [NSString stringWithFormat:@"%@_%@", organism.genus, organism.species];
    WikipediaHelper *wikipediaHelper = [[WikipediaHelper alloc] init];
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    // Check if there is an Wikipedia entry, if there is not do not display the wiki button
    BOOL showWikipedia = [[appSettings stringForKey:@"showWikipedia"] isEqualToString:@"on"];
    if(showWikipedia){
        NSLog(@"check wikipedia article");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if([[wikipediaHelper getWikipediaHTMLPage:latName] isEqualToString:@""]) {
            wikiButton.hidden = YES;
        } else {
            wikiButton.hidden = NO;
        }
        NSLog(@"wiki end");
    }else {
        wikiButton.hidden = YES;
    }
    
    BOOL showImages = [[appSettings stringForKey:@"showImages"] isEqualToString:@"on"];
    if(showImages) {
        NSLog(@"check wikipedia image");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // Fetch image data
        NSString *imageUrl = [wikipediaHelper getUrlOfMainImage:latName];
        
        if(![imageUrl isEqualToString:@""]) {
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            picture.image = image;
            imageAuthor.text = @"© Wikipedia";
        } else {
            imageAuthor.text = @"";
        }
        NSLog(@"wiki image end");
    } else {
        picture.image = [UIImage imageNamed:@"bildvorschaudeaktiviert.png"];
        imageAuthor.text = @"";
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (void) wikipediaLinkClicked
{
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    BOOL showWikipedia = [[appSettings stringForKey:@"showWikipedia"] isEqualToString:@"on"];
    BOOL showImages = [[appSettings stringForKey:@"showImages"] isEqualToString:@"on"];
    if(showImages || showWikipedia) [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Create the ObservationsOrganismViewController
    ObservationsOrganismDetailViewWikipediaController *organismWikipediaController = [[ObservationsOrganismDetailViewWikipediaController alloc] 
                                                                      initWithNibName:@"ObservationsOrganismDetailViewWikipediaController" 
                                                                      bundle:[NSBundle mainBundle]];
    
    // Build the lat search name for the wikipedia search
    NSString *latName = [[NSString alloc] initWithFormat:@"%@_%@", organism.genus, organism.species];
    
    // Set the latname on the controller
    organismWikipediaController.latName = latName;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismWikipediaController animated:TRUE];
    organismWikipediaController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
