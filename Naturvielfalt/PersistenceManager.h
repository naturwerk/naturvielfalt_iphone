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
#import "ObservationImage.h"
#import "AreaImage.h"
#import "LocationPoint.h"
#import "Inventory.h"
#import <sqlite3.h>


#define kFilenameUser @"user.sqlite3"
#define kFilenameStatic @"db.sqlite3"


@interface PersistenceManager : NSObject {
    // the db connection for organism and organism groups (static data)
    sqlite3 *dbStatic;
    // the db connection for observations. (user data)
    sqlite3 *dbUser;
    NSString *sLanguage;
}

@property (nonatomic, assign) sqlite3 *dbStatic;
@property (nonatomic, assign) sqlite3 *dbUser;
@property (nonatomic) NSString *sLanguage;

// Connection
- (void) establishConnection;
- (void) closeConnection;

// helper for the connection method
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

// Observations
- (long long int) saveObservation:(Observation *) observation;
- (void) updateObservation:(Observation *) observation;
- (void) deleteObservation:(long long int)observationId;
- (void) deleteObservations:(NSMutableArray *)observations;
- (Observation *) getObservation:(long long int) observationId;
- (NSMutableArray *) getObservations;
- (NSMutableArray *) getAllAreaObservations;
- (NSMutableArray *) getAllSingelObservations;

// ObservationImages
- (long long int) saveObservationImage:(ObservationImage *) observationImage;
- (void) deleteObservationImage:(long long int) observationImageId;
- (void) deleteObservationImagesFromObservation:(long long int) observationId;
- (NSMutableArray *) getObservationImagesFromObservation: (long long int) observationId;

// Areas
- (long long int) saveArea:(Area *) area;
- (void) updateArea:(Area *) area;
- (void) deleteArea:(long long int) areaId;
- (NSMutableArray *) getAreas;
- (Area *) getArea:(long long int)areaId;
- (NSMutableArray *) getInventoriesFromArea:(Area *) area;

// AreaImages
- (long long int) saveAreaImage:(AreaImage *) areaImage;
- (void) deleteAreaImage:(long long int) areaImageId;
- (void) deleteAreaImagesFromArea:(long long int) areaId;
- (NSMutableArray *) getAreaImagesFromArea: (long long int) areaId;

//Inventories
- (long long int) saveInventory:(Inventory *) inventory;
- (void) updateInventory:(Inventory *) inventory;
- (void) deleteInventory:(long long int) inventoryId;
- (void) deleteInventories:(NSMutableArray *)inventories;
- (NSMutableArray *) getInventories;
- (Inventory *) getInventory:(long long int) inventoryId;
- (NSMutableArray *) getObservationsFromInventory:(Inventory *)inventory;

//Point: Needed for Area feature
- (void) saveLocationPoints: (NSMutableArray *)locationPoints areaId:(long long int)aId;
- (void) deleteLocationPoints:(long long int) aId;
- (NSMutableArray *) getLocationPointsFromArea:(long long int) areaId;

// Organismgroups;
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel;
- (BOOL) organismGroupHasChild:(int) groupId;

// Organisms
- (NSMutableArray *) getOrganisms:(int) groupId withCustomFilter:(NSString *)filter;
- (NSMutableArray *) getOrganismsSortByDE:(int) groupId withCustomFilter:(NSString*) filter;
- (NSMutableArray *) getOrganismsSortByLAT:(int) groupId withCustomFilter: (NSString*) filter;
- (NSMutableArray *) getAllOrganisms:(int) groupId sortByDe:(BOOL) sortByDe;



@end
