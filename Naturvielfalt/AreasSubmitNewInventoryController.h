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

@interface AreasSubmitNewInventoryController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    Area *area;
    Inventory *inventory;
    NSArray *arrayKeys;
    NSArray *arrayValues;
    
    BOOL review;
}

@property (nonatomic) Area *area;

@end
