//
//  AreasSubmitInvetoryObservationController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "Inventory.h"

@interface AreasSubmitInventoryObservationController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *inventoryLabel;
    IBOutlet UILabel *areaLabel;
    
    Area *area;
    Inventory *inventory;
    BOOL review;
}
@property (nonatomic) Area *area;
@property (nonatomic) Inventory *inventory;

@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *inventoryLabel;
@property (nonatomic) IBOutlet UILabel *areaLabel;

@end
