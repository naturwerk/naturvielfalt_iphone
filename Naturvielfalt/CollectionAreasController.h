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
    IBOutlet UITableView *table;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
    AlertUploadView *uploadView;
    MBProgressHUD *loadingHUD;
    IBOutlet UIButton *checkAllButton;
    IBOutlet UIImageView *checkAllView;
    IBOutlet UILabel *noEntryFoundLabel;
}

@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) NSMutableArray *areas;
@property (nonatomic) IBOutlet UIButton *checkAllButton;
@property (nonatomic) IBOutlet UIImageView *checkAllView;
@property (nonatomic) IBOutlet UILabel *noEntryFoundLabel;


- (IBAction)checkAllAreas:(id)sender;
@end
