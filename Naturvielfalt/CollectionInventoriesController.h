//
//  CollectionInventoriesController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CollectionInventoriesController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
    
    NSOperationQueue *operationQueue;
    IBOutlet UITableView *tableView;
    NSMutableArray *inventories;
    BOOL doSubmit;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *inventories;

@end
