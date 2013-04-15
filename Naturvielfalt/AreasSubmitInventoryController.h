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
    Area *area;
    
    BOOL review;
}

@property (nonatomic) Area *area;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *areaName;

- (IBAction)newInventory:(id)sender;

@end
