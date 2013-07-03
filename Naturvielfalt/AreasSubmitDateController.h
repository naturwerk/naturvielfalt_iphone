//
//  AreasSubmitDateController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"

@interface AreasSubmitDateController : UIViewController {
    
    Area *area;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel *dateLabel;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) NSDateFormatter *dateFormatter;

- (IBAction)dateChanged:(id)sender;


@end
