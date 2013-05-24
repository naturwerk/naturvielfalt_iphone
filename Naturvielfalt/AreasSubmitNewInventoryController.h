//
//  AreasSubmitNewInventoryController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "Inventory.h"
#import "PersistenceManager.h"

@interface AreasSubmitNewInventoryController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    Area *area;
    Inventory *inventory;
    NSArray *arrayKeys;
    NSArray *arrayValues;
    PersistenceManager *persistenceManager;
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *inventoryName;
    UIActionSheet *deleteInventorySheet;
    NSIndexPath *currIndexPath;
    
    BOOL review;
}

@property (nonatomic) Area *area;
@property (nonatomic) Inventory *inventory;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL review;
@property (nonatomic) IBOutlet UILabel *inventoryName;


+ (void) persistInventory:(Inventory*)ivToSave area:(Area*)areaToSave;
@end
