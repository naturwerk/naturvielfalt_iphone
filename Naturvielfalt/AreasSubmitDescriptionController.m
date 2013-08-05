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
@synthesize area, persistenceManager;

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
    area.submitted = NO;
    
    [persistenceManager establishConnection];
    [persistenceManager persistArea:area];
    [persistenceManager closeConnection];
    
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    textView = nil;
    [super viewDidUnload];
}
@end
