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
#import "AreasSubmitNewInventoryController.h"
#import "InventoriesPager.h"
#import "ACollectionController.h"

@interface CollectionInventoriesController :  ACollectionController {
    
    NSMutableArray *inventoriesToSubmit;
    int *countInventories;
    
    AreasSubmitNewInventoryController *areasSubmitNewInventoryController;
}

@end
