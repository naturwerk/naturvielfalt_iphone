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
    NSString *title = @"Inventarname";
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Speichern"
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
    
    
    // Change view back to submitController
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController = [[AreasSubmitNewInventoryController alloc]
                                                    initWithNibName:@"AreasSubmitNewInventoryController"
                                                    bundle:[NSBundle mainBundle]];
    
    
    // Switch the View & Controller
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:areasSubmitNewInventoryController animated:TRUE];
    areasSubmitNewInventoryController = nil;
}


- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
