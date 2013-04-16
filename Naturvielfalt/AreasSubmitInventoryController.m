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
@synthesize area, dateLabel, authorLabel, areaLabel;

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
    
    // Set top navigation bar button
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]
                                     initWithTitle:(!review) ? @"Sichern"
                                     : @"Ändern"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(saveArea)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set top navigation bar button
    UIBarButtonItem *chancelButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Abbrechen"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action: @selector(abortInventory)];
    self.navigationItem.leftBarButtonItem = chancelButton;
    
    // Set navigation bar title
    NSString *title = @"Inventar";
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
    
    if(!review) {
        
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        NSString *username = @"";
        
        if([appSettings objectForKey:@"username"] != nil) {
            username = [appSettings stringForKey:@"username"];
        }
        
        area.author = username;
        
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in observation data object
        area.date = now;
    }
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    nowString = [dateFormatter stringFromDate:area.date];
    
    dateLabel.text = nowString;
    areaLabel.text = area.name;
    authorLabel.text = area.author;
    
}

- (void) abortInventory {
    NSLog(@"abortInventory");
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.navigationController pushViewController:self.navigationController.parentViewController animated:TRUE];
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
    [self setAuthorLabel:nil];
    [self setAreaLabel:nil];
    [super viewDidUnload];
}

- (IBAction)newInventory:(id)sender {
    
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                 initWithNibName:@"AreasSubmitNewInventoryController"
                                 bundle:[NSBundle mainBundle]];

    
    // Switch the View & Controller
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;

}
@end
