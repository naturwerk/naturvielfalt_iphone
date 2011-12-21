//
//  ObservationsOrganismSubmitAmountController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismSubmitAmountController.h"

@implementation ObservationsOrganismSubmitAmountController
@synthesize picker;
@synthesize amount;
@synthesize arrayValues;
@synthesize observation;

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

- (void) viewDidDisappear:(BOOL)animated
{
    // If the user has edited the text field use the text field value
    observation.amount = amount.text;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithString:@"Anzahl"];
    self.navigationItem.title = title;
    
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
    
    observation = [[[Observation alloc] init] getObservation];
    amount.text = observation.amount;
    
    // set the picker value to the current stored amount value
    [picker selectRow:selectedRowId inComponent:0 animated:true];
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
    observation.amount = [arrayValues objectAtIndex:row];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void) dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
