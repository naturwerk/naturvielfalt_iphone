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
#import "AreaUploadHelper.h"
#import "AlertUploadView.h"

@interface CollectionAreasController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, Listener> {
    
    PersistenceManager *persistenceManager;
    NSMutableArray *areas;
    NSMutableArray *areasToSubmit;
    NSMutableArray *areaUploadHelpers;
    int totalRequests;
    int areasCounter;
    int totalObjectsToSubmit;
    IBOutlet UITableView *tableView;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
    AlertUploadView *uploadView;
    MBProgressHUD *loadingHUD;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *areas;

@end
