//
//  InventoryUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "Inventory.h"
#import "ObservationUploadHelper.h"
#import "ASIFormDataRequest.h"
#import "PersistenceManager.h"

@interface InventoryUploadHelper : NSObject <AUploadHelper, Observer, Listener> {
    Inventory *inventory;
    BOOL withRecursion;
    id<Listener> listener;
    ASIFormDataRequest *request;
    AsyncRequestDelegate *asyncRequestDelegate;
    NSMutableArray *observationUploadHelpers;
    int observationCounter;
    PersistenceManager *persistenceManager;
    BOOL cancelSubmission;
}

@end
