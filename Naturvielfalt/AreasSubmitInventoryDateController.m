//
//  AreasSubmitInventoryDateController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import "AreasSubmitInventoryDateController.h"
#import "AreasSubmitNewInventoryController.h"

@implementation AreasSubmitInventoryDateController
@synthesize inventory, datePicker, dateLabel, dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        persistenceManager = [[PersistenceManager alloc] init];
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
                                                                  action:@selector(saveInventoryDate)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)viewWillAppear:(BOOL)animated {
    // Get formatted date string
    NSString *nowString = [dateFormatter stringFromDate:inventory.date];
    dateLabel.text = nowString;
    datePicker.date = inventory.date;
    
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *curLanguage =[appSettings stringForKey:@"language"];
    if ([curLanguage isEqualToString:@"de"]) {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"German"];
    } else if ([curLanguage isEqualToString:@"fr"]) {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"French"];
    } else if ([curLanguage isEqualToString:@"en"]) {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"English"];
    } else if ([curLanguage isEqualToString:@"it"]) {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"Italian"];
    } else {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"English"];
    }
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

- (void) saveInventoryDate {
    inventory.date = datePicker.date;
    inventory.submitted = NO;
    
    [persistenceManager establishConnection];
    [persistenceManager persistInventory:inventory];
    [persistenceManager closeConnection];
    
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}
@end
