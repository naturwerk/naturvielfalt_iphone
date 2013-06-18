//
//  AreaUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "AUploadHelper.h"
#import "Observer.h"
#import "Listener.h"
#import "Area.h"
#import "InventoryUploadHelper.h"
#import "AsyncRequestDelegate.h"

@interface AreaUploadHelper : NSObject <AUploadHelper, Observer, Listener> {
    Area *area;
    BOOL withRecursion;
    id<Listener> listener;
    InventoryUploadHelper *inventoryUploadHelper;
    AsyncRequestDelegate *asyncRequestDelegate;
}


@end
