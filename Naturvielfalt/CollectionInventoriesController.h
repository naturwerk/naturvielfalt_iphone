//
//  CollectionInventoriesController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PersistenceManager.h"
#import "ASINetworkQueue.h"
#import "AreaUploadHelper.h"

@interface CollectionInventoriesController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
    
    MBProgressHUD *loadingHUD;
    PersistenceManager *persistenceManager;
    NSMutableArray *inventories;
    NSMutableArray *inventoriesToSubmit;
    int *countInventories;
    IBOutlet UITableView *tableView;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *inventories;

@end
