//
//  AreasSubmitDescriptionController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import "AreasSubmitDescriptionController.h"
#import "AreasSubmitController.h"

@interface AreasSubmitDescriptionController ()

@end

@implementation AreasSubmitDescriptionController
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
    NSString *title = @"Beschreibung";
    self.navigationItem.title = title;
    
    // Make the textfield get focus
    [textView becomeFirstResponder];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Speichern"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveDescription)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Load the current observation comment into the textview
    textView.text = area.description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveDescription
{
    // Save the description
    area.description = textView.text;
    
    
    // Change view back to submitController
    AreasSubmitController *areasSubmitController = [[AreasSubmitController alloc]
                                                                      initWithNibName:@"AreasSubmitController"
                                                                      bundle:[NSBundle mainBundle]];
    
    
    // Switch the View & Controller
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
    
    // PUSH
    [self.navigationController pushViewController:areasSubmitController animated:TRUE];
    areasSubmitController = nil;
}

- (void)viewDidUnload {
    textView = nil;
    [super viewDidUnload];
}
@end
