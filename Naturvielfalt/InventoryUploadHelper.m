//
//  InventoryUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "InventoryUploadHelper.h"

@implementation InventoryUploadHelper

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    withRecursion = recursion;
    
}

- (void)update:(NSObject *)object {
    inventory = (Inventory *)object;
    
    //start async request
}

- (void) registerListener:(id<Listener>)l {
    listener = l;
}

- (void) unregisterListener {
    listener = nil;
}

@end
