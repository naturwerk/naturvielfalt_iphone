//
//  AreasSubmitDateController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "PersistenceManager.h"

@interface AreasSubmitDateController : UIViewController {
    
    Area *area;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel *dateLabel;
    NSDateFormatter *dateFormatter;
    PersistenceManager *persistenceManager;
}

@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) PersistenceManager *persistenceManager;

- (IBAction)dateChanged:(id)sender;


@end
