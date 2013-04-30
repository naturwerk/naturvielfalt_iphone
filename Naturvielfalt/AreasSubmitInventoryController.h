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
    
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *autherLabel;
    IBOutlet UILabel *areaLabel;
    IBOutlet UILabel *inventoryLabel;
    IBOutlet UIImageView *areaImage;
    IBOutlet UITableView *inventoriesTable;
    Area *area;
    
    BOOL review;
}

@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *autherLabel;
@property (nonatomic) IBOutlet UILabel *inventoryLabel;
@property (nonatomic) IBOutlet UILabel *areaLabel;
@property (nonatomic) IBOutlet UIImageView *areaImage;
@property (nonatomic) IBOutlet UITableView *inventoriesTable;

- (IBAction)newInventory:(id)sender;

@end
