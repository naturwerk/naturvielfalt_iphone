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
#import "CollectionAreaObservationsController.h"
#import "SingleObservationPager.h"
#import "AreaObservationsPager.h"
#import "AreasPager.h"
#import "InventoriesPager.h"

@implementation CollectionOverviewController
@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        observationsController = [[CollectionObservationsController alloc]initWithNibName:@"CollectionObservationsController" bundle:[NSBundle mainBundle]];
        NMPaginator *pagerObsSingle = [[SingleObservationPager alloc] initWithPageSize:10 delegate:observationsController];
        [observationsController setPager:pagerObsSingle];
        
        areaObservationsController = [[CollectionAreaObservationsController alloc]initWithNibName:@"CollectionAreaObservationsController" bundle:[NSBundle mainBundle]];
        NMPaginator *pagerObsArea = [[AreaObservationsPager alloc] initWithPageSize:10 delegate:areaObservationsController];
        [areaObservationsController setPager:pagerObsArea];
        
        inventoriesController = [[CollectionInventoriesController alloc]initWithNibName:@"CollectionInventoriesController" bundle:[NSBundle mainBundle]];
        NMPaginator *pagerInv = [[InventoriesPager alloc] initWithPageSize:10 delegate:inventoriesController];
        [inventoriesController setPager:pagerInv];
        
        areasController = [[CollectionAreasController alloc]initWithNibName:@"CollectionAreasController" bundle:[NSBundle mainBundle]];
        NMPaginator *pagerArea = [[AreasPager alloc] initWithPageSize:10 delegate:areasController];
        [areasController setPager:pagerArea];
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
    arrayKeys = [[NSArray alloc] initWithObjects:NSLocalizedString(@"collectionSingelObsTitle", nil), NSLocalizedString(@"collectionAreaObsTitle", nil), NSLocalizedString(@"areaSubmitInventory", nil), NSLocalizedString(@"areaTabLabel", nil), nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if (section == 0) {
        return 1;
    } else {
        return arrayKeys.count -1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"standardCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Use normal cell layout
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if (indexPath.section == 0) {
        // Set up the cell...
        cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];
    } else {
         cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row +1];
    }


    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    NSLog(@"index Path: %i", indexPath.row);
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {

                case 0:
                    {
                        // SINGEL OBSERVATIONS
                        [self.navigationController pushViewController:observationsController animated:YES];
                        
                        break;
                    }
        }
    } else {
        switch (indexPath.row) {
            case 0:
            {
                // AREA OBSERVATIONS
                [self.navigationController pushViewController:areaObservationsController animated:YES];
                break;
            }

            case 1:
                {
                    // INVENTORIES
                    [self.navigationController pushViewController:inventoriesController animated:YES];
                    break;
                }
                
            case 2:
                {
                    // AREAS
                    [self.navigationController pushViewController:areasController animated:YES];
                    break;
                }
        }
    }
}



@end
