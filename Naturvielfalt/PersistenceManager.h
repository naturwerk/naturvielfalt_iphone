//
//  PersistenceManager.h
//  Naturvielfalt
//
//  Created by Robin Oster on 27.10.11.
//  Copyright (c) 2011 Naturwerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Observation.h"
#import "Area.h"
#import "Inventory.h"
#import <sqlite3.h>


#define kFilenameUser @"user.sqlite3"
#define kFilenameStatic @"db.sqlite3"


@interface PersistenceManager : NSObject {
    // the db connection for organism and organism groups (static data)
    sqlite3 *dbStatic;
    // the db connection for observations. (user data)
    sqlite3 *dbUser;
}

@property (nonatomic, assign) sqlite3 *dbStatic;
@property (nonatomic, assign) sqlite3 *dbUser;

// Connection
- (void) establishConnection;
- (void) closeConnection;

// helper for the connection method
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

// Observations
- (long long int) saveObservation:(Observation *) observation;
- (void) updateObservation:(Observation *) observation;
- (void) deleteObservation:(long long int)observationId;
- (NSMutableArray *) getObservations;

// Areas
- (long long int) saveArea:(Area *) area;
- (void) updateArea:(Area *) area;
- (void) deleteArea:(long long int) areaId;
- (NSMutableArray *) getAreas;
- (NSMutableArray *) getInventoriesFromArea:(long long int) areaId;

//Inventories
- (long long int) saveInventory:(Inventory *) inventory;
- (void) updateInventory:(Inventory *) inventory;
- (void) deleteInventory:(long long int) inventoryId;
- (NSMutableArray *) getInventories;
- (NSMutableArray *) getObservationsFromInventory:(long long int) inventoryId;

// Organismgroups;
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel;
- (BOOL) organismGroupHasChild:(int) groupId;

// Organisms
- (NSMutableArray *) getOrganisms:(int) groupId withCustomFilter:(NSString *)filter;
- (NSMutableArray *) getAllOrganisms:(int) groupId;



@end
