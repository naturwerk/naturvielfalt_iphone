//
//  ObservationsOrganismSubmitAmountController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismSubmitAmountController.h"
#import "ObservationsOrganismSubmitController.h"

@implementation ObservationsOrganismSubmitAmountController
@synthesize picker, amount, arrayValues, observation, amountLabel, currentAmount, persistenceManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"amountNavTitle", nil);
    self.navigationItem.title = title;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveAmount)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    amountLabel.text = NSLocalizedString(@"amountNavTitle", nil);
    
    // Initialize the picker
    arrayValues = [[NSMutableArray alloc] init];

    // Determine which value is currently selected. We need to find out the index
    int selectedRowId = -1;
    int selectedRowValue = [observation.amount intValue];
    int counter = 0;
    
    // 1 to 10
    for(int i = 1; i <= 10; i++) {
        if(i == selectedRowValue)
            selectedRowId = counter;
        
        [arrayValues addObject:[[NSString alloc] initWithFormat:@"%d", i]];
        
        counter++;
    }
    
    // 20 to 100
    for(int i = 20; i <= 100; i = i + 10) {
        if(selectedRowId == -1 && i == selectedRowValue)
            selectedRowId = counter;
        
        [arrayValues addObject:[[NSString alloc] initWithFormat:@"%d", i]];
        
        counter++;
    }
    
    // 200 to 500
    for(int i = 200; i <= 500; i = i + 100) {
        if(selectedRowId == -1 && i == selectedRowValue)
            selectedRowId = counter;
        
        [arrayValues addObject:[[NSString alloc] initWithFormat:@"%d", i]];
        
        counter++;
    }
    
    //observation = [[Observation alloc] getObservation];
    amount.text = observation.amount;
    currentAmount = observation.amount;
    
    // set the picker value to the current stored amount value
    [picker selectRow:selectedRowId inComponent:0 animated:true];
}

- (void) viewDidAppear:(BOOL)animated {
    if (observation.observationId) {
        if (!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        observation = [persistenceManager getObservation:observation.observationId];
        Area *tmpArea = [persistenceManager getArea:observation.inventory.areaId];
        observation.inventory.area = tmpArea;
        
        if (!observation) {
            [observation setObservation:nil];
            observation = nil;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
}

- (void) saveAmount {
    observation.amount = currentAmount;
    if (observation.inventory) {
        observation.inventory.area.submitted = NO;
    }
    [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
    
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayValues count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayValues objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // update value of the amount text field
    amount.text = [arrayValues objectAtIndex:row];
    //observation.amount = [arrayValues objectAtIndex:row];
    currentAmount = [arrayValues objectAtIndex:row];
}

- (void)viewDidUnload
{
    [self setAmountLabel:nil];
    [super viewDidUnload];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
