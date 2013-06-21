//
//  AreaUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "InventoryUploadHelper.h"
#import "PersistenceManager.h"
#import "ASIFormDataRequest.h"

@interface AreaUploadHelper : NSObject <AUploadHelper, Observer, Listener> {
    Area *area;
    BOOL withRecursion;
    id<Listener> listener;
    ASIFormDataRequest *request;
    AsyncRequestDelegate *asyncRequestDelegate;
    NSMutableArray *inventoryUploadHelpers;
    int inventoryCounter;
}


@end
