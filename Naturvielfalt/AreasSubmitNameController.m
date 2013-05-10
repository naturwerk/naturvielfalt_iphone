//
//  AreasSubmitNameController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitNameController.h"
#import "AreasSubmitController.h"

@interface AreasSubmitNameController ()

@end

@implementation AreasSubmitNameController
@synthesize area;

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
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"areaSubmitName", nil);
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveAreaName)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Load the current observation comment into the textview
    textView.text = area.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveAreaName
{
    // Save the description
    area.name = textView.text;
    
    if (area.areaId) {
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        [persistenceManager updateArea:area];
        [persistenceManager closeConnection];
    }
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)viewDidUnload {
    textView = nil;
    [super viewDidUnload];
}
@end
