//
//  CollectionAreaObservationsController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 20.06.13.
//
//

#import <UIKit/UIKit.h>
#import "PersistenceManager.h"
#import "MBProgressHUD.h"

@interface CollectionAreaObservationsController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    
    IBOutlet UITableView *table;
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    int *countObservations;
    NSIndexPath *curIndex;
    
    NSOperationQueue *operationQueue;
    MBProgressHUD *loadingHUD;
    
}

@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic) NSIndexPath *curIndex;

@end
