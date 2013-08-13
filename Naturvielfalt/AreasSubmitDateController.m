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
@synthesize area, dateLabel, datePicker, dateFormatter, persistenceManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        persistenceManager  = [[PersistenceManager alloc] init];
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

- (void) saveAreaDate {
    area.date = datePicker.date;
    area.submitted = NO;
    [persistenceManager establishConnection];
    [persistenceManager persistArea:area];
    [persistenceManager closeConnection];
    
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}
@end
