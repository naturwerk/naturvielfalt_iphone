//
//  Area.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 04.04.13.
//
//

#import "Area.h"
#import "Inventory.h"

@class AreasViewController;
@implementation Area
@synthesize areaId, author, name, date, pictures, inventories, description, submitToServer, locationLocked, typeOfArea, latitudeArray, longitudeArray, persisted;

- (id) init {
    
    if (self = [super init]) {
        areaId = 1;
        author = @"Hans Muster";
        name = @"Area 1";
        date = [NSDate date];
        pictures = nil;
        description = @"Description 1";
        persisted = NO;
        
        for (int i = 0; i < 4; i++) {
            Inventory *inv = [[Inventory alloc] init];
            inv.name = [NSString stringWithFormat:@"Inventar %i", i];
            inv.description = @"Libellen-Inventar";
            [inventories addObject:inv];
        }
    }
    return self;
}


@end
