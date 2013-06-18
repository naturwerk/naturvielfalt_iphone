//
//  Area.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 04.04.13.
//
//

#import "Area.h"
#import "Inventory.h"
#import "Observation.h"

@class AreasViewController;
@implementation Area
@synthesize areaId, author, name, date, pictures, inventories, description, submitToServer, locationLocked, typeOfArea, persisted, locationPoints, guid;

static Area *area;

- (Area *) getArea {
    
    @synchronized(self)
    {
        if (!area) {
            pictures = [[NSMutableArray alloc] init];
            inventories = [[NSMutableArray alloc] init];
            area = [[Area alloc] init];
            area.locationLocked = false;
            area.author = @"";
            area.date = [NSDate date];
            area.name = @"";
            area.description = @"";
            area.pictures = pictures;
            area.inventories = inventories;
            area.guid = 0;
            
            
            //test data
            /*for (int i = 0; i < 4; i++) {
                Inventory *inv = [[Inventory alloc] getInventory];
                inv.author = area.author;
                inv.date = [NSDate date];
                inv.name = [NSString stringWithFormat:@"Inventar %i", i];
                inv.description = @"Libellen-Inventar";
                [area.inventories addObject:inv];
                [inv setInventory:nil];
            }*/
        }
        return area;
    }
}

- (void) setArea:(Area *)a
{
    area = a;
}



@end
