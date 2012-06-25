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
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, self.view.frame.size.height + 20);
    
    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithString:@"Naturvielfalt"];
    self.navigationItem.title = title;
    
    NSString *partner = [[NSString alloc] initWithString:@"Unsere Partner:"];
    self.lblPartner.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    self.lblPartner.text = partner;
    
    //NSString *infoFlora = [[NSString alloc] initWithString:@"Info Flora(CRSF)"];
    //self.lblInfoFlora.font = [UIFont fontWithName:@"Helvetica" size:14];
    //self.lblInfoFlora.text = infoFlora;
    
    CGRect frameIMGView = CGRectMake(20, 250, 80, 80); // Replacing with your dimensions
    UIView *VImages = [[UIView alloc] initWithFrame:frameIMGView];
    
    UIImage *imgInfoflora = [UIImage imageNamed:@"logo.infoflora.57.png"];
    CGRect frameInfoflora = CGRectMake(0, 0, imgInfoflora.size.width, imgInfoflora.size.height); // Replacing with your dimensions
    UIImageView *ivPartnerInfoflora = [[UIImageView alloc] initWithFrame:frameInfoflora];
    ivPartnerInfoflora.image = imgInfoflora;
    
    
    [VImages addSubview:ivPartnerInfoflora];
    [self.view addSubview:VImages];
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
