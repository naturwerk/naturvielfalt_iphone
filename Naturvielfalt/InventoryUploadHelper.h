//
//  InventoryUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "AUploadHelper.h"
#import "Observer.h"
#import "Inventory.h"

@interface InventoryUploadHelper : NSObject <AUploadHelper, Observer> {
    Inventory *inventory;
    BOOL withRecursion;
    id<Listener> listener;
}

@end
