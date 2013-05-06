//
//  CollectionOverviewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionOverviewController.h"
#import "CollectionObservationsController.h"
#import "CollectionInventoriesController.h"
#import "CollectionAreasController.h"

@implementation CollectionOverviewController
@synthesize table;

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
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"collectionNavTitle", nil);
    self.navigationItem.title = title;
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:NSLocalizedString(@"observationTabLabel", nil), NSLocalizedString(@"areaSubmitInventory", nil), NSLocalizedString(@"areaTabLabel", nil), nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    return arrayKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"standardCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Use normal cell layout
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    // Set up the cell...
    cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    NSLog(@"index Path: %i", indexPath.row);
    CollectionObservationsController *collectionObservationsController;
    CollectionInventoriesController *collectionInventoriesController;
    CollectionAreasController *collectionAreasController;
    
    
    switch (indexPath.row) {
        case 0:
        {
            // OBSERVATIONS 
            // Create the CollectionObservationsController
            collectionObservationsController = [[CollectionObservationsController alloc]initWithNibName:@"CollectionObservationsController" bundle:[NSBundle mainBundle]];
            
            
            // Switch the View & Controller
            [self.navigationController pushViewController:collectionObservationsController animated:TRUE];
            collectionObservationsController = nil;
            
            break;
        }
        case 1:
        {
            // INVENTORIES
            // Create the CollectionInventoriesController
            collectionInventoriesController = [[CollectionInventoriesController alloc]initWithNibName:@"CollectionInventoriesController" bundle:[NSBundle mainBundle]];
            
            // Switch the View & Controller
            [self.navigationController pushViewController:collectionInventoriesController animated:TRUE];
            //collectionInventoriesController = nil;
            
            break;
        }
        case 2:
        {
            // AREAS
            // Create the CollectionAreasController
            collectionAreasController = [[CollectionAreasController alloc]
                                               initWithNibName:@"CollectionAreasController"
                                               bundle:[NSBundle mainBundle]];
            
            // Switch the View & Controller
            [self.navigationController pushViewController:collectionAreasController animated:TRUE];
            collectionAreasController = nil;
            
            break;
        }
    }
}



@end
