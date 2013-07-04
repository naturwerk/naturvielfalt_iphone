//
//  ObservationsOrganismSubmitDateController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 02.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Observation.h"

@interface ObservationsOrganismSubmitDateController : UIViewController <UIPickerViewDelegate>{
    
    Observation *observation;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel *dateLabel;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic) Observation *observation;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) IBOutlet UILabel *dateLabel;
- (IBAction)dateChanged:(id)sender;

@end
