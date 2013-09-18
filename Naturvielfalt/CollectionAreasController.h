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
#import "AreasSubmitController.h"
#import "AreasPager.h"
#import "ACollectionController.h"

@interface CollectionAreasController : ACollectionController <Listener, UIAlertViewDelegate, ASIHTTPRequestDelegate> {
    
    NSMutableArray *areasToSubmit;
    NSMutableArray *areaUploadHelpers;
    int totalRequests;
    int areasCounter;
    int totalObjectsToSubmit;
    IBOutlet UITableView *table;
    BOOL cancelSubmission;
    BOOL submissionFail;
    BOOL authorized;
    IBOutlet UIButton *checkAllButton;
    IBOutlet UIImageView *checkAllView;
    AreasSubmitController *areasSubmitController;
}

@property (nonatomic) IBOutlet UIButton *checkAllButton;
@property (nonatomic) IBOutlet UIImageView *checkAllView;


- (IBAction)checkAllAreas:(id)sender;

@end
