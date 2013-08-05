//
//  AreasSubmitInventoryDateController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Inventory.h"
#import "PersistenceManager.h"

@interface AreasSubmitInventoryDateController : UIViewController {
    
    Inventory *inventory;
    IBOutlet UILabel *dateLabel;
    IBOutlet UIDatePicker *datePicker;
    NSDateFormatter *dateFormatter;
    PersistenceManager *persistenceManager;
}

@property (nonatomic) Inventory *inventory;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)dateChanged:(id)sender;
@end
