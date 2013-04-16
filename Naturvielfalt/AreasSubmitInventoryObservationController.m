//
//  AreasSubmitInvetoryObservationController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import "AreasSubmitInventoryObservationController.h"

@interface AreasSubmitInventoryObservationController ()

@end

@implementation AreasSubmitInventoryObservationController
@synthesize dateLabel, inventoryLabel, areaLabel, area, inventory;

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
    // Do any additional setup after loading the view from its nib.
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
    [super viewDidUnload];
}

- (void) prepareData {
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowString = [dateFormatter stringFromDate:inventory.date];
    dateLabel.text = nowString;
    
    inventoryLabel.text = inventory.name;
    areaLabel.text = area.name;
}
@end
