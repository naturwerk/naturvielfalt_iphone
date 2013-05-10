//
//  AreasSubmitInventoryNameController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitInventoryNameController.h"
#import "AreasSubmitNewInventoryController.h"

@interface AreasSubmitInventoryNameController ()

@end

@implementation AreasSubmitInventoryNameController
@synthesize textView, inventory;

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
    NSString *title = NSLocalizedString(@"areaSubmitInventoryName", nil);
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveInventoryName)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Load the current observation comment into the textview
    textView.text = inventory.name;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveInventoryName
{
    // Save the description
    inventory.name = textView.text;
    
    if (inventory.inventoryId) {
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        [persistenceManager updateInventory:inventory];
        [persistenceManager closeConnection];
    }
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}


- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
