//
//  Inventory.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.04.13.
//
//

#import "Inventory.h"
#import "Observation.h"

@implementation Inventory 
@synthesize inventoryId, author, name, description, date, pictures, submitToServer, area, observations;

static Inventory *inventory;

- (Inventory *) getInventory {
    
    @synchronized(self)
    {
        if (!inventory) {
            observations = [[NSMutableArray alloc] init];
            pictures = [[NSMutableArray alloc] init];
            inventory = [[Inventory alloc] init];
            inventory.author = @"";
            inventory.name = @"";
            inventory.description = @"";
            inventory.date = [NSDate date];
            inventory.observations = observations;
            inventory.pictures = pictures;
            
            //test data
            /*for (int i = 0; i < 4; i++) {
                Observation *obs = [[Observation alloc] getObservation];
                obs.author = inventory.author;
                obs.date = [NSDate date];
                obs.inventory = self;
                Organism *org = [[Organism alloc] init];
                org.genus = @"";
                org.nameDe = [NSString stringWithFormat:@"Organism %i", i];
                org.nameLat = @"";
                obs.organism = org;
                obs.amount = [NSString stringWithFormat:@"%i", i];
                [inventory.observations addObject:obs];
                [obs setObservation:nil];
            }*/
        }
        return inventory;
    }
}

- (void) setInventory:(Inventory *)iv
{
    inventory = iv;
}

@end
