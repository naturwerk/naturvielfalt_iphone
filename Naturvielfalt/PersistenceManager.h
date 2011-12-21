//
//  PersistenceManager.h
//  Naturvielfalt
//
//  Created by Robin Oster on 27.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observation.h"
#import <sqlite3.h>


#define kFilename @"db.sqlite3"

@interface PersistenceManager : NSObject {
    sqlite3 *database;
}

@property (nonatomic, assign) sqlite3 *database;

// Connection
- (void) establishConnection;
- (void) closeConnection;

// Observations
- (int *) saveObservation:(Observation *) observation;
- (void) updateObservation:(Observation *) observation;
- (void) deleteObservation:(int)observationId;
- (NSMutableArray *) getObservations;

// Organismgroups;
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel;
- (BOOL) organismGroupHasChild:(int) groupId;

// Organisms
- (NSMutableArray *) getAllOrganisms:(int) groupId;



@end
