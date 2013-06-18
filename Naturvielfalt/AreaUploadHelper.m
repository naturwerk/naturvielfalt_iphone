//
//  AreaUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "AreaUploadHelper.h"
#import "Area.h"

@implementation AreaUploadHelper

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    withRecursion = recursion;
    if (object.class != [Area class]) {
        return;
    }
    area = (Area *) object;
    
    if (withRecursion) {
        if (!inventoryUploadHelper) {
            inventoryUploadHelper = [[InventoryUploadHelper alloc] init];
        }
        asyncRequestDelegate = [[AsyncRequestDelegate alloc] initWithObject:area];
        
    }
}

- (void)update:(NSObject *)object {
    area = (Area *)object;
    
    //start async request
    
}

- (void) registerListener:(id<Listener>)l {
    listener = l;
}

- (void) unregisterListener {
    listener = nil;
}

- (void) notifyListener:(NSObject *)object response:(NSString *)response {
    if (object.class != [Area class]) {
        return;
    } else if ((Area *)object != area) {
        return;
    }
    
}


@end
