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
    IBOutlet UILabel *amountLabel;
    NSMutableArray *arrayValues;
    Observation *observation;
    NSString *currentAmount;
    
}

@property (nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic) IBOutlet UITextField *amount;
@property (nonatomic) IBOutlet NSMutableArray *arrayValues;
@property (nonatomic) IBOutlet Observation *observation;
@property (nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic) IBOutlet NSString *currentAmount;

@end
