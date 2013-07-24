//
//  PersistenceManager.m
//  Naturvielfalt
//
//  Created by Robin Oster on 27.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PersistenceManager.h"
#import "OrganismGroup.h"
#import "Organism.h"
#import "sys/xattr.h"

@implementation PersistenceManager
@synthesize dbStatic, dbUser, sLanguage;
int UNKNOWN_ORGANISMGROUPID = 1000;
int UNKNOWN_ORGANISMID      =   -1;

- (NSString *)userDataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0] ;
    return [documentsDirectory stringByAppendingPathComponent:kFilenameUser];
}

- (NSString *)staticDataFilePath {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kFilenameStatic ofType:nil]; 
    return filePath;
}

// CONNECTION
- (void) establishConnection
{
    // Create link to user database
    if (sqlite3_open([[self userDataFilePath] UTF8String], &dbUser) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert(0, @"Failed to open user database");
    }
    
    sLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if (![sLanguage isEqualToString:@"en"] && ![sLanguage isEqualToString:@"de"] &&
        ![sLanguage isEqualToString:@"fr"] && ![sLanguage isEqualToString:@"it"]) {
        // English if unsupported system language is setted
        sLanguage = @"en";
    }
    
    // Store the language in the appSettings
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    [appSettings setObject:sLanguage forKey:@"language"];
    [appSettings synchronize];
    
    // create link to static database
    NSString *staticPath = [self staticDataFilePath];
    NSLog(@"%s", [staticPath UTF8String]);
    int state = sqlite3_open([staticPath UTF8String], &dbStatic);
    if (state != SQLITE_OK) {
        sqlite3_close(dbStatic);
        NSAssert(0, @"Failed to open static database");
    }
    
    // Create TABLE (At the moment IMAGE BLOB is missing..)
    // Create TABLE OBSERVATION
    NSString *createSQLObservation = @"CREATE TABLE IF NOT EXISTS observation (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
    INVENTORY_ID INTEGER,                 \
    ORGANISM_ID INTEGER,                  \
    ORGANISMGROUP_ID INTEGER,             \
    ORGANISM_NAME TEXT,                   \
    ORGANISM_NAME_LAT TEXT,               \
    ORGANISM_FAMILY TEXT,                 \
    AUTHOR TEXT,                          \
    DATE TEXT,                            \
    AMOUNT INTEGER,                       \
    LOCATION_LAT REAL,                    \
    LOCATION_LON REAL,                    \
    ACCURACY INTEGER,                     \
    COMMENT TEXT);";
    
    
    // Create TABLE observationImage
    NSString *createSQLObservationImage = @"CREATE TABLE IF NOT EXISTS observationImage (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
    OBSERVATION_ID INTEGER,                             \
    IMAGE BLOB);";
    
    char *errorMsg;
    
    if (sqlite3_exec (dbUser, [createSQLObservation UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table: %s", errorMsg);
    }
    sqlite3_finalize((__bridge sqlite3_stmt *)(createSQLObservation));
    
    if (sqlite3_exec (dbUser, [createSQLObservationImage UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table OBSERVATIONIMAGE: %s", errorMsg);
    }
    sqlite3_finalize((__bridge sqlite3_stmt *)(createSQLObservationImage));
    
    // dont' backup the database files to iCloud
    NSString *userPath = [self userDataFilePath];
    NSURL* userUrl = [NSURL fileURLWithPath:userPath];
    [self addSkipBackupAttributeToItemAtURL:userUrl];
}

// found somewhere in the internet...
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    if (&NSURLIsExcludedFromBackupKey == nil) {
        // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else {
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                NSLog(@"Removed extended attribute on file %@", URL);
            }
        }
        
        // Set the new key
        return [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

- (void) closeConnection
{
    // Disconnect link to database
    sqlite3_close(dbUser);
    sqlite3_close(dbStatic);
}

// OBSERVATIONS
- (long long int) saveObservation:(Observation *) observation
{
    char *sql = "INSERT INTO observation (INVENTORY_ID, ORGANISM_ID, ORGANISMGROUP_ID, ORGANISM_NAME, ORGANISM_NAME_LAT, ORGANISM_FAMILY, AUTHOR, DATE, AMOUNT, LOCATION_LAT, LOCATION_LON, ACCURACY, COMMENT) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:observation.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, observation.inventoryId);
        sqlite3_bind_int(stmt, 2, observation.organism.organismId);
        sqlite3_bind_int(stmt, 3, observation.organism.organismGroupId);
        sqlite3_bind_text(stmt, 4, [[observation.organism getNameDe] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[observation.organism getLatName] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [observation.organism.family UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [observation.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 8, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 9, [observation.amount intValue]);
        sqlite3_bind_double(stmt, 10, observation.location.coordinate.latitude);
        sqlite3_bind_double(stmt, 11, observation.location.coordinate.longitude);
        sqlite3_bind_int(stmt, 12, observation.accuracy);
        sqlite3_bind_text(stmt, 13, [observation.comment UTF8String], -1, NULL);
    }
    
    NSLog(@"Insert observation in db: %@", observation);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", observation);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);
}

- (void) updateObservation:(Observation *) observation
{
    // Delete all images from observation first
    [self deleteObservationImagesFromObservation:observation.observationId];
    
    char *sql = "UPDATE observation SET INVENTORY_ID = ?, ORGANISM_ID = ?, ORGANISMGROUP_ID = ?, ORGANISM_NAME = ?, ORGANISM_NAME_LAT = ?, ORGANISM_FAMILY = ?, AUTHOR = ?, DATE = ?, AMOUNT = ?, LOCATION_LAT = ?, LOCATION_LON = ?, ACCURACY = ?, COMMENT = ? WHERE ID = ?";
    
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:observation.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, observation.inventoryId);
        sqlite3_bind_int(stmt, 2, observation.organism.organismId);
        sqlite3_bind_int(stmt, 3, observation.organism.organismGroupId);
        sqlite3_bind_text(stmt, 4, [[observation.organism getNameDe] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[observation.organism getLatName] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [observation.organism.family UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [observation.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 8, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 9, [observation.amount intValue]);
        sqlite3_bind_double(stmt, 10, observation.location.coordinate.latitude);
        sqlite3_bind_double(stmt, 11, observation.location.coordinate.longitude);
        sqlite3_bind_int(stmt, 12, observation.accuracy);
        sqlite3_bind_text(stmt, 13, [observation.comment UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 14, observation.observationId);
        
        // Check if there are any images
        if(observation.pictures.count > 0) {
            for (ObservationImage *obsImg in observation.pictures) {
                obsImg.observationId = observation.observationId;
                obsImg.observationImageId = [self saveObservationImage:obsImg];
            }
        }
        NSLog(@"Update observation in db: %@", observation);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", observation);
    }
    
    sqlite3_finalize(stmt);
}

- (Observation *) getObservation:(long long int) observationId {
    Observation *observation;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM observation WHERE ID = '%lld'", observationId];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int observationId = sqlite3_column_int(statement, 0);
            int inventoryId = sqlite3_column_int(statement, 1);
            int organismId = sqlite3_column_int(statement, 2);
            int organismGroupId = sqlite3_column_int(statement, 3);
            //NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            //NSString *organismNameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
            int amount = sqlite3_column_int(statement, 9);
            double locationLat = sqlite3_column_double(statement, 10);
            double locationLon = sqlite3_column_double(statement, 11);
            int accuracy = sqlite3_column_int(statement, 12);
            NSString *comment;
            NSString *organismFamily;
            
            
            // Check if the organismFamily is null
            if(sqlite3_column_text(statement, 6) == NULL) {
                organismFamily = @"";
            } else {
                organismFamily = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            }
            
            // Check if the comment is null
            if(sqlite3_column_text(statement, 13) == NULL) {
                comment = @"";
            } else {
                comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
            }
            
            // Create organism and set the id
            Organism *organism = [[Organism alloc] init];
            organism.organismId = organismId;
            organism.organismGroupId = organismGroupId;
            organism.organismGroupName = [self getOrganismGroupTranslationName:organismGroupId];
            //organism.nameDe = organismNameDe;
            if (organismGroupId == UNKNOWN_ORGANISMGROUPID) {
                organism.nameDe = NSLocalizedString(@"unknownOrganism", nil);
                organism.nameLat = @"";
                organism.genus = @"";
                organism.species = @"";
            } else {
                NSString *organismNameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                organism.nameDe = [self getOrganismTranslationName:organismId];
                
                // Split the lat name into two pieces
                NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
                
                if([latNames count] == 2) {
                    organism.genus = [latNames objectAtIndex:0];
                    organism.species = [latNames objectAtIndex:1];
                } else {
                    organism.genus = @"";
                    organism.species = @"";
                }
            }
            
            organism.family = organismFamily;
            
            // Split the lat name into two pieces
            /*NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
            
            if([latNames count] == 2) {
                organism.genus = [latNames objectAtIndex:0];
                organism.species = [latNames objectAtIndex:1];
            } else {
                organism.genus = @"";
                organism.species = @"";
            }*/
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            
            NSString *amountString = [[NSString alloc] initWithFormat:@"%d", amount];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:locationLat longitude:locationLon];
            
            // Create observation
            observation = [[Observation alloc] init];
            observation.observationId = observationId;
            observation.inventoryId = inventoryId;
            observation.organism = organism;
            observation.author = author;
            observation.date = date;
            observation.amount = amountString;
            observation.location = location;
            observation.accuracy = accuracy;
            observation.comment = comment;
            observation.submitToServer = true;
            observation.pictures = [self getObservationImagesFromObservation:observationId];
            
            // Create organismGroup
            int classlevel = 1;
            int parentId = 1;
            observation.organismGroup = [self getOrganismGroup:parentId withClasslevel:classlevel andOrganismGroupId:organismGroupId];
		}
        sqlite3_finalize(statement);
    }
    return observation;
}

- (NSMutableArray *) getObservations
{
    // All observations are stored in here
    NSMutableArray *observations = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM observation ORDER BY DATE DESC";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            
            int observationId = sqlite3_column_int(statement, 0);
            int inventoryId = sqlite3_column_int(statement, 1);
            int organismId = sqlite3_column_int(statement, 2);
            int organismGroupId = sqlite3_column_int(statement, 3);
            //NSString *organismGroupName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            //NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            NSString *organismNameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
            int amount = sqlite3_column_int(statement, 9);
            double locationLat = sqlite3_column_double(statement, 10);
            double locationLon = sqlite3_column_double(statement, 11);
            int accuracy = sqlite3_column_int(statement, 12);
            NSString *comment;
            NSString *organismFamily;
            
            
            // Check if the comment is null
            if(sqlite3_column_text(statement, 6) == NULL) {
                organismFamily = @"";
            } else {
                organismFamily = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            }
            
            // Check if the comment is null
            if(sqlite3_column_text(statement, 13) == NULL) {
                comment = @"";
            } else {
                comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
            }
            
            // Create organism and set the id
            Organism *organism = [[Organism alloc] init];
            organism.organismId = organismId;
            organism.organismGroupId = organismGroupId;
            organism.organismGroupName = [self getOrganismGroupTranslationName:organismGroupId];
            //organism.nameDe = organismNameDe;
            if (organismGroupId == UNKNOWN_ORGANISMGROUPID) {
                organism.nameDe = NSLocalizedString(@"unknownOrganism", nil);
                
                organism.genus = @"";
                organism.species = @"";
            } else {
                organism.nameDe = [self getOrganismTranslationName:organismId];
                
                // Split the lat name into two pieces
                NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
                
                if([latNames count] == 2) {
                    organism.genus = [latNames objectAtIndex:0];
                    organism.species = [latNames objectAtIndex:1];
                } else {
                    organism.genus = @"";
                    organism.species = @"";
                }
            }
            
            organism.family = organismFamily;
            
            // Split the lat name into two pieces
            /*NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
             
             if([latNames count] == 2) {
             organism.genus = [latNames objectAtIndex:0];
             organism.species = [latNames objectAtIndex:1];
             } else {
             organism.genus = @"";
             organism.species = @"";
             }*/
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            
            NSString *amountString = [[NSString alloc] initWithFormat:@"%d", amount];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:locationLat longitude:locationLon];
            
            // Create observation
            Observation *observation = [[Observation alloc] init];
            //observation.inventory = [self getInventory:inventoryId];
            observation.observationId = observationId;
            observation.inventoryId = inventoryId;
            observation.organism = organism;
            observation.author = author;
            observation.date = date;
            observation.amount = amountString;
            observation.location = location;
            observation.accuracy = accuracy;
            observation.comment = comment;
            observation.submitToServer = true;
            observation.pictures = [self getObservationImagesFromObservation:observationId];
            
            // Get OrganismGroup
            int classlevel = 1;
            int parentId = 1;
            observation.organismGroup = [self getOrganismGroup:parentId withClasslevel:classlevel andOrganismGroupId:organismGroupId];
            
            // Add observation to the observation array
            [observations addObject:observation];
		}
        sqlite3_finalize(statement);
    }
    return observations;
}

// Organismname with right translation
- (NSString *) getOrganismTranslationName:(int)organismId {
    
    if (organismId == UNKNOWN_ORGANISMID) {
        return NSLocalizedString(@"unknownOrganism", nil);
    }
    
    NSString *result;
    NSString *query = [NSString stringWithFormat:@"SELECT name_%@ FROM organism WHERE organism_id = '%i'", sLanguage, organismId];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            if ([result isEqualToString:@""]) {
                result = NSLocalizedString(@"organismNoTransAvailable", nil);
            }
		}
        sqlite3_finalize(statement);
    }
    return result;
}

// Organismname with right translation
- (NSString *) getOrganismGroupTranslationName:(int)organismGroupId {
    
    NSString *result;
    NSString *query = [NSString stringWithFormat:@"SELECT name_%@ FROM classification WHERE classification_id = '%i'", sLanguage, organismGroupId];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            if ([result isEqualToString:@""]) {
                result = NSLocalizedString(@"organismNoTransAvailable", nil);
            }
		}
        sqlite3_finalize(statement);
    }
    return result;
}

- (void) deleteObservation:(long long int)observationId
{
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM observation WHERE ID = '%lld'", observationId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Observation deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    [self deleteObservationImagesFromObservation:observationId];
    // Finalize and close database.
    sqlite3_finalize(statement);
}

- (void) deleteObservations:(NSMutableArray *)observations {
    for (Observation *observation in observations) {
        [self deleteObservation:observation.observationId];
    }
}

// ObservationImages
- (long long int) saveObservationImage:(ObservationImage *) observationImage {
    
    char *sql = "INSERT INTO observationImage (OBSERVATION_ID, IMAGE) VALUES (?, ?)";
    sqlite3_stmt *stmt;
    
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, observationImage.observationId);
        
        NSData *imageData = UIImagePNGRepresentation(observationImage.image);
        sqlite3_bind_blob(stmt, 2, [imageData bytes] , [imageData length], NULL);
    }
    
    NSLog(@"Insert observationImage in db: %@", observationImage);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", observationImage);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);
}

- (void) deleteObservationImage:(long long int) observationImageId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM observationImage WHERE ID = '%lld'", observationImageId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"ObservationImage deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
}

- (void) deleteObservationImagesFromObservation:(long long int) observationId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM observationImage WHERE OBSERVATION_ID = '%lld'", observationId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"ObservationImages deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
}
- (NSMutableArray *) getObservationImagesFromObservation: (long long int) observationId {
    // All observations are stored in here
    NSMutableArray *observationImages = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM observationImage WHERE OBSERVATION_ID = '%lld'", observationId];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int observationImageId = sqlite3_column_int(statement, 0);
            int observationId = sqlite3_column_int(statement, 1);
            
            // Get the image
            NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 2) length:sqlite3_column_bytes(statement, 2)];
            UIImage *image = [UIImage imageWithData:data];
            
            
            // Create observationImage
            ObservationImage *observationImage = [[ObservationImage alloc] init];
            observationImage.observationImageId = observationImageId;
            observationImage.observationId = observationId;
            observationImage.image = image;
            
            // Add observationImage to the observationImages array
            [observationImages addObject:observationImage];
		}
        sqlite3_finalize(statement);
    }
    return observationImages;
}



// ORGANISMGROUPS
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel
{
    //[self authUser];
    NSDate *starttime = [NSDate date];
    NSMutableArray *organismGroups = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT c.classification_id, c.name_%@, COUNT(ct.taxon_id), c.position \
                       FROM classification as c \
                       LEFT JOIN classification_taxon as ct ON ct.classification_id = c.classification_id \
                       WHERE (c.parent = %d) AND (ct.display_level = 1 OR ct.display_level is NULL) \
                       GROUP BY c.classification_id, c.name_%@ ORDER BY c.position", sLanguage, parentId, sLanguage];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int classificationId = sqlite3_column_int(statement, 0);
            NSString *groupName;
            if (!(char *)sqlite3_column_text(statement, 1)) {
                groupName = NSLocalizedString(@"organismNoTransAvailable", nil);
            } else {
                groupName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                if (groupName.length == 0) {
                    groupName = NSLocalizedString(@"organismNoTransAvailable", nil);
                }
            }
        
            int groupCount = sqlite3_column_int(statement, 2);
            
            // Create OrganismGroup
            OrganismGroup *organismGroup = [[OrganismGroup alloc] init];
            
            organismGroup.organismGroupId = classificationId;
            organismGroup.name = groupName;
            organismGroup.count = groupCount;
            
            [organismGroups addObject:organismGroup];
		}
        
        sqlite3_finalize(statement);
    }
    
    //Add unknown art to the list
    /*OrganismGroup *unknownGroup = [[OrganismGroup alloc] init];
    unknownGroup.organismGroupId = 1000;
    unknownGroup.name = NSLocalizedString(@"unknownArt", nil);
    unknownGroup.count = 0;
    [organismGroups insertObject:unknownGroup atIndex:0];*/
    
    NSDate *endtime = [NSDate date];
    NSTimeInterval executionTime = [endtime timeIntervalSinceDate:starttime];
    NSLog(@"PersistenceManager: getAllOrganismGroups(parentId: %i, classlevel: %i) | running time: %fs", parentId, classlevel, executionTime);
    return organismGroups;
}

- (BOOL) organismGroupHasChild:(int) groupId {
    
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM classification WHERE parent = %d", groupId];
    
    sqlite3_stmt *statement;
    
    int count = 0;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		sqlite3_step(statement);
        count = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
    }
    
    return (count > 0);
}

- (OrganismGroup *) getOrganismGroup:(int)parentId withClasslevel:(int)classlevel andOrganismGroupId:(int)organismGroupId{
    //[self authUser];
    NSDate *starttime = [NSDate date];
    OrganismGroup *organismGroup;
    
    if (organismGroupId != UNKNOWN_ORGANISMGROUPID) {
        NSString *query = [NSString stringWithFormat:@"SELECT c.classification_id, c.name_%@, COUNT(ct.taxon_id), c.position \
                           FROM classification as c \
                           LEFT JOIN classification_taxon as ct ON ct.classification_id = c.classification_id \
                           WHERE (c.parent = %d) AND (ct.display_level = 1 OR ct.display_level is NULL) \
                           AND c.classification_id = %d\
                           GROUP BY c.classification_id, c.name_%@ ORDER BY c.position", sLanguage, parentId, organismGroupId, sLanguage];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                int classificationId = sqlite3_column_int(statement, 0);
                NSString *groupName;
                if (!(char *)sqlite3_column_text(statement, 1)) {
                    groupName = NSLocalizedString(@"organismNoTransAvailable", nil);
                } else {
                    groupName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    if (groupName.length == 0) {
                        groupName = NSLocalizedString(@"organismNoTransAvailable", nil);
                    }
                }
                
                int groupCount = sqlite3_column_int(statement, 2);
                
                // Create OrganismGroup
                organismGroup = [[OrganismGroup alloc] init];
                
                organismGroup.organismGroupId = classificationId;
                organismGroup.name = groupName;
                organismGroup.count = groupCount;
            }
            
            sqlite3_finalize(statement);
        }
    } else {
        //Add unknown art to the list
        OrganismGroup *unknownGroup = [[OrganismGroup alloc] init];
        unknownGroup.organismGroupId = UNKNOWN_ORGANISMGROUPID;
        unknownGroup.name = NSLocalizedString(@"unknownArt", nil);
        unknownGroup.count = 0;
        organismGroup = unknownGroup;
    }
    
    NSDate *endtime = [NSDate date];
    NSTimeInterval executionTime = [endtime timeIntervalSinceDate:starttime];
    NSLog(@"PersistenceManager: getAllOrganismGroups(parentId: %i, classlevel: %i) | running time: %fs", parentId, classlevel, executionTime);
    return organismGroup;
}

// ORGANISMS
- (NSMutableArray *) getOrganismsSortByDE:(int) groupId withCustomFilter:(NSString*) filter {
    NSDate *starttime = [NSDate date];
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSMutableString *query;
    if(groupId == 1){
        query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_%@, name_sc \
                 FROM organism", sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                 FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);
    }
    else {
        query = [[NSMutableString alloc] initWithString: [NSString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_%@ AS name_%@, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id", sLanguage, sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id"];
        
        //Append Filter to query
        if([filter length] != 0){
            [query appendString:filter];
        }
        else {
            [query appendFormat:@" WHERE ct.classification_id = %i", groupId];
            [query appendString:[NSString stringWithFormat:@" ORDER BY name_%@ ", sLanguage]];
            //[query appendFormat:@" ORDER BY name_de "];
        }
        
        NSLog( @"Get single group, group id: %i", groupId);
    }
    
    NSLog( @"DA QUERY: %@", query);
    
    sqlite3_stmt *statement;
    NSInteger numbersOfOrgansim = 0;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            // need to check if they are Null!
            NSString *nameDe;
            NSString *nameLat;
            
            if(sqlite3_column_text(statement, 3) == NULL) {
                //nameLat = [NSString stringWithString:@""];
                // if no lat name, skip this
                continue;
            } else {
                nameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            }
            
            if(sqlite3_column_text(statement, 2) == NULL) {
                nameDe = nameLat;
            } else {
                nameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                if([nameDe length] == 0) nameDe = NSLocalizedString(@"organismNoTransAvailable", nil);
            }
            
            // Create OrganismGroup
            Organism *organism = [[Organism alloc] init];
            
            organism.organismId = sqlite3_column_int(statement, 0);
            organism.organismGroupId = sqlite3_column_int(statement, 1);
            organism.nameDe = nameDe;
            organism.nameLat = nameLat;
            
            // Split into species, genus
            NSArray *firstSplit = [organism.nameLat componentsSeparatedByString:@" "];
            
            if([firstSplit count] >= 2) {
                NSString *genus = (NSString*)[firstSplit objectAtIndex:0];
                NSString *species = (NSString*)[firstSplit objectAtIndex:1];
                
                organism.genus = genus;
                organism.species = species;
            } else {
                organism.genus = @"";
                organism.species = @"";
            }
            [organisms addObject:organism];
            organism = nil;
            numbersOfOrgansim++;
		}
        sqlite3_finalize(statement);
    } else {
        NSLog( @"Get organisms: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbStatic));
    }
    NSDate *endtime = [NSDate date];
    NSTimeInterval executionTime = [endtime timeIntervalSinceDate:starttime];
    NSLog(@"PersistenceManager: getAllOrganisms(%i) | running time: %fs", numbersOfOrgansim, executionTime);
    return organisms;
}

- (NSMutableArray *) getOrganismsSortByLAT:(int) groupId withCustomFilter: (NSString*) filter {
    NSDate *starttime = [NSDate date];
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSMutableString *query;
    if(groupId == 1){
        query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_%@, name_sc \
                 FROM organism", sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                 FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);
    }
    else {
        query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_%@ AS name_%@, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id", sLanguage, sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id"];
        
        //Append Filter to query
        if([filter length] != 0){
            [query appendString:filter];
        }
        else {
            [query appendFormat:@" WHERE ct.classification_id = %i", groupId];
            [query appendFormat:@" ORDER BY name_sc "];
        }
        
        NSLog( @"Get single group, group id: %i", groupId);
    }
    
    NSLog( @"DA QUERY: %@", query);
    
    sqlite3_stmt *statement;
    NSInteger numbersOfOrgansim = 0;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            // need to check if they are Null!
            NSString *nameDe;
            NSString *nameLat;
            
            if(sqlite3_column_text(statement, 3) == NULL) {
                //nameLat = [NSString stringWithString:@""];
                // if no lat name, skip this
                continue;
            } else {
                nameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            }
            
            if(sqlite3_column_text(statement, 2) == NULL) {
                nameDe = nameLat;
            } else {
                nameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                if([nameDe length] == 0) nameDe = NSLocalizedString(@"organismNoTransAvailable", nil);
            }
            
            // Create OrganismGroup
            Organism *organism = [[Organism alloc] init];
            
            organism.organismId = sqlite3_column_int(statement, 0);
            organism.organismGroupId = sqlite3_column_int(statement, 1);
            organism.nameDe = nameDe;
            organism.nameLat = nameLat;
            
            // Split into species, genus
            NSArray *firstSplit = [organism.nameLat componentsSeparatedByString:@" "];
            
            if([firstSplit count] >= 2) {
                NSString *genus = (NSString*)[firstSplit objectAtIndex:0];
                NSString *species = (NSString*)[firstSplit objectAtIndex:1];
                
                organism.genus = genus;
                organism.species = species;
            }else {
                organism.genus = @"";
                organism.species = @"";
            }
            [organisms addObject:organism];
            organism = nil;
            numbersOfOrgansim++;
		}
        sqlite3_finalize(statement);
    } else {
        NSLog( @"Get organisms: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbStatic));
    }
    NSDate *endtime = [NSDate date];
    NSTimeInterval executionTime = [endtime timeIntervalSinceDate:starttime];
    NSLog(@"PersistenceManager: getAllOrganisms(%i) | running time: %fs", numbersOfOrgansim, executionTime);
    return organisms;

}

- (NSMutableArray *) getOrganisms:(int) groupId withCustomFilter:(NSString *)filter
{
    NSDate *starttime = [NSDate date];
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSMutableString *query;
    if(groupId == 1){
        query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_%@, name_sc \
                 FROM organism", sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                 FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);
    }
    else {
        query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_%@ AS name_%@, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id", sLanguage, sLanguage]];
        //query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id"];
        
        //Append Filter to query
        if([filter length] != 0){
            [query appendString:filter];
        }
        else {
            [query appendFormat:@" WHERE ct.classification_id = %i", groupId];
        }
        
        NSLog( @"Get single group, group id: %i", groupId);
    }
    
    NSLog( @"DA QUERY: %@", query);
    
    sqlite3_stmt *statement;
    NSInteger numbersOfOrgansim = 0;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            // need to check if they are Null!
            NSString *nameDe;
            NSString *nameLat;
            
            if(sqlite3_column_text(statement, 3) == NULL) {
                //nameLat = [NSString stringWithString:@""];
                // if no lat name, skip this
                continue;
            } else {
                nameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            }
            
            if(sqlite3_column_text(statement, 2) == NULL) {
                nameDe = nameLat;
            } else {
                nameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                if([nameDe length] == 0) nameDe = NSLocalizedString(@"organismNoTransAvailable", nil);
            }
            
            // Create OrganismGroup
            Organism *organism = [[Organism alloc] init];
            
            organism.organismId = sqlite3_column_int(statement, 0);
            organism.organismGroupId = sqlite3_column_int(statement, 1);
            organism.nameDe = nameDe;
            organism.nameLat = nameLat;
            
            // Split into species, genus
            NSArray *firstSplit = [organism.nameLat componentsSeparatedByString:@" "];
            
            if([firstSplit count] >= 2) {
                NSString *genus = (NSString*)[firstSplit objectAtIndex:0];
                NSString *species = (NSString*)[firstSplit objectAtIndex:1];
                
                organism.genus = genus;
                organism.species = species;
            }else {
                organism.genus = @"";
                organism.species = @"";
            }
            [organisms addObject:organism];
            organism = nil;
            numbersOfOrgansim++;
		}
        sqlite3_finalize(statement);
    } else {
        NSLog( @"Get organisms: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbStatic));
    }
    NSDate *endtime = [NSDate date];
    NSTimeInterval executionTime = [endtime timeIntervalSinceDate:starttime];
    NSLog(@"PersistenceManager: getAllOrganisms(%i) | running time: %fs", numbersOfOrgansim, executionTime);
    return organisms;
}

- (NSMutableArray *) getAllOrganisms:(int) groupId sortByDe:(BOOL)sortByDe
{
    NSMutableArray *allOrganisms;
    if (sortByDe) {
        allOrganisms = [self getOrganismsSortByDE:groupId withCustomFilter:@""];
    } else {
        allOrganisms = [self getOrganismsSortByLAT:groupId withCustomFilter:@""];
    }
    //allOrganisms =[self getOrganisms:groupId withCustomFilter:@""];
    
    //add unknown organismus into array
    /*Organism *unknownOrganism = [[Organism alloc] init];
    unknownOrganism.organismId = UNKNOWN_ORGANISMID;
    unknownOrganism.organismGroupId = groupId;
    unknownOrganism.nameDe = NSLocalizedString(@"unknownOrganism", nil);
    
    [allOrganisms insertObject:unknownOrganism atIndex:0];*/
    
    return allOrganisms;
}

@end
