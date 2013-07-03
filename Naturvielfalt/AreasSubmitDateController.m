//
//  AreasSubmitDateController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import "AreasSubmitDateController.h"
#import "AreasSubmitController.h"


@implementation AreasSubmitDateController
@synthesize area, dateLabel, datePicker, dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
                                                                  action:@selector(saveAreaDate)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

-(void)viewWillAppear:(BOOL)animated {
    // Get formatted date string
    NSString *nowString = [dateFormatter stringFromDate:area.date];
    dateLabel.text = nowString;
    datePicker.date = area.date;
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
- (IBAction)dateChanged:(id)sender {
    // Get formatted date string
    NSString *nowString = [dateFormatter stringFromDate:datePicker.date];
    dateLabel.text = nowString;
}

- (void) saveAreaDate {
    area.date = datePicker.date;
    area.submitted = NO;
    [AreasSubmitController persistArea:area];
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}
@end
