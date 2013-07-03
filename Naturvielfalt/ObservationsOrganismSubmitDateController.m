//
//  ObservationsOrganismSubmitDateController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 02.07.13.
//
//

#import "ObservationsOrganismSubmitDateController.h"
#import "ObservationsOrganismSubmitController.h"


@implementation ObservationsOrganismSubmitDateController
@synthesize observation, datePicker, dateLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get formatted date string
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"dateNavTitle", nil);
    self.navigationItem.title = title;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveDate)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) viewWillAppear:(BOOL)animated {
    // Get formatted date string
    NSString *nowString = [dateFormatter stringFromDate:observation.date];
    dateLabel.text = nowString;
    datePicker.date = observation.date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setDateLabel:nil];
    [super viewDidUnload];
}

- (void) saveDate {
    observation.date = datePicker.date;
    if (observation.inventory) {
        observation.inventory.area.submitted = NO;
    }
    [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)dateChanged:(id)sender {
    // Get formatted date string
    NSString *nowString = [dateFormatter stringFromDate:datePicker.date];
    dateLabel.text = nowString;
}
@end
