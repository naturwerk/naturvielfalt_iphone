//
//  ObservationsOrganismSubmitAmountController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"

@interface ObservationsOrganismSubmitAmountController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UITextField *amount;
    IBOutlet UIPickerView *picker;
    NSMutableArray *arrayValues;
    Observation *observation;
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) IBOutlet UITextField *amount;
@property (nonatomic, retain) IBOutlet NSMutableArray *arrayValues;
@property (nonatomic, retain) IBOutlet Observation *observation;

@end
