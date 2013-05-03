//
//  CollectionAreasController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PersistenceManager.h"
#import "ASINetworkQueue.h"

@interface CollectionAreasController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
    
    PersistenceManager *persistenceManager;
    NSMutableArray *areas;
    NSMutableArray *areasToSubmit;
    int *countAreas;
    IBOutlet UITableView *tableView;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *areas;

@end
