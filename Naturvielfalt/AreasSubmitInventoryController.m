//
//  AreasSubmitInventoryController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitInventoryController.h"
#import "AreasSubmitNewInventoryController.h"


@interface AreasSubmitInventoryController ()

@end

@implementation AreasSubmitInventoryController
@synthesize area, dateLabel, areaLabel, autherLabel;

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
    
    NSLog(@"load settings for save area view");
    
    // Set navigation bar title
    NSString *title = @"Inventare";
    self.navigationItem.title = title;
    
    // Table init
    inventoryTableView.delegate = self;
    
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    [self prepareData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareData
{
    NSString *nowString;
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:area.date];
    
    dateLabel.text = nowString;
    areaLabel.text = area.name;
    autherLabel.text = area.author;
    
}

- (void) newInventory:(id)sender {
    NSLog(@"new inventory pressed");
    // new INVENTORY
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                                            initWithNibName:@"AreasSubmitNewInventoryController"
                                                                            bundle:[NSBundle mainBundle]];
    
    areasSubmitNewInventoryController.area = area;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;
}

#pragma mark
#pragma UITableViewDelegate Methodes

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath");
    return nil;
}


- (void)viewDidUnload {
    inventoryTableView = nil;
    [self setDateLabel:nil];
    [self setAutherLabel:nil];
    [self setAreaLabel:nil];
    [self setAutherLabel:nil];
    [super viewDidUnload];
}

@end
