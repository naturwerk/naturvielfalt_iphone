//
//  Inventory.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.04.13.
//
//

#import "Inventory.h"

@implementation Inventory 
@synthesize inventoryId, author, name, description, date, pictures, submitToServer, area, observations;

- (id) init {
    
    if (self = [super init]) {
        inventoryId = 1;
        author = @"Hans Muster";
        name = @"Libelleninventar";
        date = [NSDate date];
        pictures = nil;
        description = @"Inventory description 1";
    }
    return self;
}

@end
