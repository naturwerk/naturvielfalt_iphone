//
//  AreasSubmitInvetoryObservationController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import "AreasSubmitInventoryObservationController.h"
#import "ObservationsViewController.h"

@interface AreasSubmitInventoryObservationController ()

@end

@implementation AreasSubmitInventoryObservationController
@synthesize dateLabel, inventoryLabel, areaLabel, area, inventory, observationsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load settings for save observation view");
    
    // Set navigation bar title
    NSString *title = @"Beobachtungen";
    self.navigationItem.title = title;
    
    // Table init
    observationsTableView.delegate = self;
    
    [self prepareData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDateLabel:nil];
    [self setInventoryLabel:nil];
    [self setAreaLabel:nil];
    [self setObservationsTableView:nil];
    [super viewDidUnload];
}

- (void) prepareData {
    
    
    if (inventory) {
        NSLog(@"not empty");
    }
    NSString *nowString;
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:inventory.date];
    
    dateLabel.text = nowString;    
    inventoryLabel.text = inventory.name;
    areaLabel.text = area.name;
}

- (IBAction)newObservation:(id)sender {
    NSLog(@"new inventory pressed");
    // new INVENTORY
    ObservationsViewController *observationsViewController = [[ObservationsViewController alloc]
                                                                            initWithNibName:@"ObservationsViewController"
                                                                            bundle:[NSBundle mainBundle]];
    
    observationsViewController.inventory = inventory;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:observationsViewController animated:TRUE];
    observationsViewController = nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath");
    return nil;
}

@end
