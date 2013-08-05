//
//  AreasSubmitInventoryDescriptionController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitInventoryDescriptionController.h"
#import "AreasSubmitNewInventoryController.h"

@interface AreasSubmitInventoryDescriptionController ()

@end

@implementation AreasSubmitInventoryDescriptionController
@synthesize textView, inventory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"areaSubmitDescr", nil);
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveDescription)];
    
    self.navigationItem.rightBarButtonItem = backButton;
    
    // Load the current observation comment into the textview
    textView.text = inventory.description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveDescription
{
    // Save the description
    inventory.description = textView.text;
    inventory.submitted = NO;
    
    [persistenceManager establishConnection];
    [persistenceManager persistInventory:inventory];
    [persistenceManager closeConnection];
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
