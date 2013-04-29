//
//  AreasSubmitInventoryController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"

@interface AreasSubmitInventoryController : UIViewController <UITableViewDelegate> {
    
    IBOutlet UITableView *inventoryTableView;
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *autherLabel;
    IBOutlet UILabel *areaLabel;
    IBOutlet UILabel *inventoryLabel;
    Area *area;
    
    BOOL review;
}

@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *autherLabel;
@property (nonatomic) IBOutlet UILabel *inventoryLabel;
@property (nonatomic) IBOutlet UILabel *areaLabel;

- (IBAction)newInventory:(id)sender;

@end
