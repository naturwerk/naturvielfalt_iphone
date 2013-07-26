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
    
    if ([inventory.name compare:@""] == 0) {
        self.navigationItem.leftBarButtonItem = backButton;
    } else {
        self.navigationItem.rightBarButtonItem = backButton;
    }
    
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
    inventory.submitted = NO;
    
    if ([inventory.name compare:@""] == 0) {
        UIAlertView *inventoryAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertMessageInventoryTitle", nil)
                                                                 message:NSLocalizedString(@"alertMessageInventoryName", nil) delegate:self cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [inventoryAlert show];
        return;
    } else {
        [AreasSubmitNewInventoryController persistInventory: inventory area:inventory.area];
    }

    [AreasSubmitNewInventoryController persistInventory:inventory area:inventory.area];
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}


- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
