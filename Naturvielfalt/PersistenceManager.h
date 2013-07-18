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
#import "ObservationImage.h"
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
@property NSString *sLanguage;

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

- (NSString *) getOrganismTranslationName:(int)organismId;
- (NSString *) getOrganismGroupTranslationName:(int)organismId;

// ObservationImages
- (long long int) saveObservationImage:(ObservationImage *) observationImage;
- (void) deleteObservationImage:(long long int) observationImageId;
- (void) deleteObservationImagesFromObservation:(long long int) observationId;
- (NSMutableArray *) getObservationImagesFromObservation: (long long int) observationId;

// Organismgroups;
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel;
- (BOOL) organismGroupHasChild:(int) groupId;
- (OrganismGroup *) getOrganismGroup:(int) parentId withClasslevel:(int) classlevel andOrganismGroupId:(int) organismGroupId;

// Organisms
- (NSMutableArray *) getOrganisms:(int) groupId withCustomFilter:(NSString *)filter;
- (NSMutableArray *) getOrganismsSortByDE:(int) groupId withCustomFilter:(NSString*) filter;
- (NSMutableArray *) getOrganismsSortByLAT:(int) groupId withCustomFilter: (NSString*) filter;
- (NSMutableArray *) getAllOrganisms:(int) groupId sortByDe:(BOOL) sortByDe;


@end
