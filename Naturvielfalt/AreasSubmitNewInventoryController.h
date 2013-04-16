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

@interface AreasSubmitNewInventoryController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    Area *area;
    Inventory *inventory;
    NSArray *arrayKeys;
    NSArray *arrayValues;
    PersistenceManager *persistenceManager;
    IBOutlet UITableView *tableView;
    
    BOOL review;
}

@property (nonatomic) Area *area;
@property (nonatomic) Inventory *inventory;
@property (nonatomic) IBOutlet UITableView *tableView;

@end
