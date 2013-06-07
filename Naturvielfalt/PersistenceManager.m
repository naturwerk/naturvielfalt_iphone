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
@synthesize dbStatic;
@synthesize dbUser;

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
    
    // create link to static database
    NSString *staticPath = [self staticDataFilePath];
    NSLog(@"%s", [staticPath UTF8String]);
    int state = sqlite3_open([staticPath UTF8String], &dbStatic);
    if (state != SQLITE_OK) {
        sqlite3_close(dbStatic);
        NSAssert(0, @"Failed to open static database");
    }
	
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
    
    // Create TABLE INVENTORY (At the moment IMAGE BLOB is missing..)
    NSString *createSQLInventory = @"CREATE TABLE IF NOT EXISTS inventory (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                     AREA_ID INTEGER,                      \
                                                                     NAME TEXT,                            \
                                                                     AUTHOR TEXT,                          \
                                                                     DATE TEXT,                            \
                                                                     DESCRIPTION TEXT);";
    
    // Create TABLE AREA
    NSString *createSQLArea = @"CREATE TABLE IF NOT EXISTS area (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                    NAME TEXT,                             \
                                                                    MODE INT,                              \
                                                                    AUTHOR TEXT,                           \
                                                                    DATE TEXT,                             \
                                                                    DESCRIPTION TEXT);";
    
    // Create TABLE LocationPoint
    NSString *createSQLLocationPoint = @"CREATE TABLE IF NOT EXISTS locationPoint (AREA_ID INTEGER,        \
                                                                    LAT REAL,                              \
                                                                    LON REAL);";
    
    // Create TABLE areaImage
    NSString *createSQLAreaImage = @"CREATE TABLE IF NOT EXISTS areaImage (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                                    AREA_ID INTEGER,                             \
                                                                    IMAGE BLOB);";
    
    // Create TABLE observationImage
    NSString *createSQLObservationImage = @"CREATE TABLE IF NOT EXISTS observationImage (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
    OBSERVATION_ID INTEGER,                             \
    IMAGE BLOB);";
    
    char *errorMsg;
    
    if (sqlite3_exec (dbUser, [createSQLObservation UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table OBSERVATION: %s", errorMsg);
    }
    
    if (sqlite3_exec (dbUser, [createSQLInventory UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table INVENTORY: %s", errorMsg);
    }
    
    if (sqlite3_exec (dbUser, [createSQLArea UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table AREA: %s", errorMsg);
    }
    
    if (sqlite3_exec (dbUser, [createSQLLocationPoint UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table LOCATIONPOINT: %s", errorMsg);
    }
    
    if (sqlite3_exec (dbUser, [createSQLAreaImage UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table AREAIMAGE: %s", errorMsg);
    }
    
    if (sqlite3_exec (dbUser, [createSQLObservationImage UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table OBSERVATIONIMAGE: %s", errorMsg);
    }
    
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
        sqlite3_bind_int(stmt, 1, observation.inventory.inventoryId);
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
        sqlite3_bind_int(stmt, 1, observation.inventory.inventoryId);
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
            NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
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
            organism.nameDe = organismNameDe;
            organism.family = organismFamily;
            
            // Split the lat name into two pieces
            NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
            
            if([latNames count] == 2) {
                organism.genus = [latNames objectAtIndex:0];
                organism.species = [latNames objectAtIndex:1];
            } else {
                organism.genus = @"";
                organism.species = @"";
            }
            
            
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
            
            if (inventoryId != 0) {
                // observation is member of an inventory
                observation.inventory = [self getInventory:inventoryId];
            }
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
            NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
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
            organism.nameDe = organismNameDe;
            organism.family = organismFamily;
            
            // Split the lat name into two pieces
            NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
            
            if([latNames count] == 2) {
                organism.genus = [latNames objectAtIndex:0];
                organism.species = [latNames objectAtIndex:1];
            } else {
                organism.genus = @"";
                organism.species = @"";
            }
            
            
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
            
            if (inventoryId != 0) {
                // observation is member of an inventory
                observation.inventory = [self getInventory:inventoryId];
                observation.inventory.area = [self getArea:observation.inventory.areaId];
                //inventory.area.inventories = [self getInventoriesFromArea:inventory.area];
            }
            
            // Add observation to the observation array
            [observations addObject:observation];
		}
        sqlite3_finalize(statement);
    }
    
    return observations;
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

// AREAS
- (long long int) saveArea:(Area *) area {
    
    char *sql = "INSERT INTO area (NAME, MODE, AUTHOR, DATE, DESCRIPTION) VALUES (?, ?, ?, ?, ?)";
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:area.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [[area name] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, area.typeOfArea);
        sqlite3_bind_text(stmt, 3, [area.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[area description] UTF8String], -1, NULL);
        

        // Check if there are any images, if yes then save it. Doesn't work because areaId is missing at this point
        /*if(area.pictures.count > 0) {
            for (AreaImage *areaImg in area.pictures) {
                if (!areaImg.areaImageId) {
                    areaImg.areaImageId = [self saveAreaImage:areaImg];
                }
            }
        }*/
    }
    
    // Check for inventories, doesn't work because areaId is missing at this point
    /*if (area.inventories.count > 0) {
        for (Inventory *inventory in area.inventories) {
            inventory.inventoryId = [self saveInventory:inventory];
        }
    }*/
    
    NSLog(@"Insert area in db: %@", area);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", area);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);
}

- (void) updateArea:(Area *) area {
    char *sql = "UPDATE area SET NAME = ?, MODE = ?, AUTHOR = ?, DATE = ?, DESCRIPTION = ? WHERE ID = ?";
    
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:area.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [[area name] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, area.typeOfArea);
        sqlite3_bind_text(stmt, 3, [[area author] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[area description] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, area.areaId);

        // Check if there are any images
        if(area.pictures.count > 0) {
            for (AreaImage *areaImg in area.pictures) {
                if (!areaImg.areaImageId) {
                    areaImg.areaImageId = [self saveAreaImage:areaImg];
                }
            }
        }
        [self saveLocationPoints:area.locationPoints areaId:area.areaId];
        NSLog(@"Update area in db: %@", area);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", area);
    }
    
    sqlite3_finalize(stmt);
}

- (void) deleteArea:(long long int) areaId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM area WHERE ID = '%lld'", areaId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Area deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    [self deleteLocationPoints:areaId];
    [self deleteAreaImagesFromArea:areaId];
    // Finalize and close database.
    sqlite3_finalize(statement);
}

- (NSMutableArray *) getAreas {
    // All observations are stored in here
    NSMutableArray *areas = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM area ORDER BY DATE DESC";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int areaId = sqlite3_column_int(statement, 0);
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            int mode = sqlite3_column_int(statement, 2);
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            
            NSString *description;
            
            // Check if description is null
            if(sqlite3_column_text(statement, 5) == NULL) {
                description = @"";
            } else {
                description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            // Create area
            Area *area = [[Area alloc] init];
            area.areaId = areaId;
            area.name = name;
            area.author = author;
            area.date = date;
            area.description = description;
            area.submitToServer = true;
            area.pictures = [self getAreaImagesFromArea:areaId];
            area.persisted = YES;
            
            switch (mode) {
                case 1: {area.typeOfArea = POINT; break;}
                case 2: {area.typeOfArea = LINE; break;}
                case 4: {area.typeOfArea = POLYGON;break;}
            }
            
            area.locationPoints = [self getLocationPointsFromArea:areaId];
            area.inventories = [self getInventoriesFromArea:area];

            
            // Add area to the areas array
            [areas addObject:area];
		}
        sqlite3_finalize(statement);
    }
    return areas;
}

- (Area *) getArea:(long long int)areaId {
    
    Area *area;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM area WHERE ID = '%lld'", areaId];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            int mode = sqlite3_column_int(statement, 2);
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            
            NSString *description;
            
            // Check if description is null
            if(sqlite3_column_text(statement, 5) == NULL) {
                description = @"";
            } else {
                description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            }
        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            // Create Inventory
            area = [[Area alloc] init];
            area.areaId = areaId;
            //area.inventories = [self getInventoriesFromArea:areaId];
            area.name = name;
            area.author = author;
            area.date = date;
            area.description = description;
            area.submitToServer = true;
            area.pictures = [self getAreaImagesFromArea:areaId];
        
            switch (mode) {
                case 1: {area.typeOfArea = POINT; break;}
                case 2: {area.typeOfArea = LINE; break;}
                case 4: {area.typeOfArea = POLYGON;break;}
            }
            
            area.inventories = [self getInventoriesFromArea:area];
            area.locationPoints = [self getLocationPointsFromArea:areaId];
        }
        sqlite3_finalize(statement);
    }
    return area;
}

// AreaImages
- (long long int) saveAreaImage:(AreaImage *) areaImage {
    
    char *sql = "INSERT INTO areaImage (AREA_ID, IMAGE) VALUES (?, ?)";
    sqlite3_stmt *stmt;
    
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, areaImage.areaId);
        
        NSData *imageData = UIImagePNGRepresentation(areaImage.image);
        sqlite3_bind_blob(stmt, 2, [imageData bytes] , [imageData length], NULL);
    }
    
    NSLog(@"Insert observationImage in db: %@", areaImage);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", areaImage);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);
}
- (void) deleteAreaImage:(long long int) areaImageId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM areaImage WHERE ID = '%lld'", areaImageId];
    
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
- (void) deleteAreaImagesFromArea:(long long int) areaId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM areaImage WHERE AREA_ID = '%lld'", areaId];
    
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
- (NSMutableArray *) getAreaImagesFromArea: (long long int) areaId {
    // All areaImages are stored in here
    NSMutableArray *areaImages = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM areaImage WHERE AREA_ID = '%lld'", areaId];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int areaImageId = sqlite3_column_int(statement, 0);
            int areaId = sqlite3_column_int(statement, 1);
            
            // Get the image
            NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 2) length:sqlite3_column_bytes(statement, 2)];
            UIImage *image = [UIImage imageWithData:data];
            
            
            // Create areaImage
            AreaImage *areaImage = [[AreaImage alloc] init];
            areaImage.areaImageId = areaImageId;
            areaImage.areaId = areaId;
            areaImage.image = image;
            
            // Add areaImage to the areaImages array
            [areaImages addObject:areaImage];
		}
        sqlite3_finalize(statement);
    }
    return areaImages;

}

- (void) saveLocationPoints: (NSMutableArray *)locationPoints areaId:(long long)aId{
    char *sql = "INSERT INTO locationPoint (AREA_ID, LAT, LON) VALUES (?, ?, ?)";
    sqlite3_stmt *stmt;
    
    [self deleteLocationPoints:aId];
    
    for (LocationPoint *lp in locationPoints) {
    // Put the data into the insert statement
        if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
            
            
                sqlite3_bind_int(stmt, 1, aId);
                sqlite3_bind_double(stmt, 2, lp.latitude);
                sqlite3_bind_double(stmt, 3, lp.longitude);
            
            
            NSLog(@"Insert locationPoints in db:");
            
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                NSAssert1(0, @"Error inserting into table: %@", LocationPoint.class);
            }
            sqlite3_finalize(stmt);
        }
    }
}

- (void) deleteLocationPoints:(long long int)aId{
    sqlite3_stmt* statement;
    

    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM locationPoint WHERE AREA_ID = '%lld'", aId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    // Finalize and close database.
    sqlite3_finalize(statement);
}

- (NSMutableArray *) getLocationPointsFromArea:(long long int) areaId {
    // All points are stored in here
    NSMutableArray *locationPoints = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM locationPoint WHERE AREA_ID = '%lld'", areaId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int areaId = sqlite3_column_int(statement, 0);
            double locationLat = sqlite3_column_double(statement, 1);
            double locationLon = sqlite3_column_double(statement, 2);
            
            // Create locataion point
            LocationPoint *locationPoint = [[LocationPoint alloc] init];
            locationPoint.areaId = areaId;
            locationPoint.longitude = locationLon;
            locationPoint.latitude = locationLat;
            
            // Add points to the locationsPoints array
            [locationPoints addObject:locationPoint];
		}
        sqlite3_finalize(statement);
    }
    return locationPoints;
}

- (NSMutableArray *) getInventoriesFromArea:(Area *)area {
    // All inventories are stored in here
    NSMutableArray *inventories = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM inventory WHERE AREA_ID = '%lld' ORDER BY DATE DESC", area.areaId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int inventoryId = sqlite3_column_int(statement, 0);
            //int areaId = sqlite3_column_int(statement, 1);
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            
            NSString *description;
            
            // Check if description is null
            if(sqlite3_column_text(statement, 5) == NULL) {
                description = @"";
            } else {
                description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            // Create Inventory
            Inventory *inventory = [[Inventory alloc] init];
            inventory.areaId = area.areaId;
            inventory.area = area;
            inventory.inventoryId = inventoryId;
            inventory.name = name;
            inventory.author = author;
            inventory.date = date;
            inventory.description = description;
            inventory.submitToServer = true;
            inventory.observations = [self getObservationsFromInventory:inventory];
            
            // Add area to the areas array
            [inventories addObject:inventory];
		}
        sqlite3_finalize(statement);
    }
    return inventories;

}

// INVENTORIES
- (long long int) saveInventory:(Inventory *) inventory {
    char *sql = "INSERT INTO inventory (AREA_ID, NAME, AUTHOR, DATE, DESCRIPTION) VALUES (?, ?, ?, ?, ?)";
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:inventory.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, inventory.area.areaId);
        sqlite3_bind_text(stmt, 2, [[inventory name] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [inventory.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[inventory description] UTF8String], -1, NULL);
    }
    
    // Check for observations, doesn't work because inventoryId is missing at this part
    /*if (inventory.observations.count > 0) {
        for (Observation *observation in inventory.observations) {
            observation.observationId = [self saveObservation:observation];
        }
    }*/
    
    NSLog(@"Insert inventory in db: %@", inventory);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", inventory);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);

}

- (void) updateInventory:(Inventory *) inventory {
    char *sql = "UPDATE inventory SET AREA_ID = ?, NAME = ?, AUTHOR = ?, DATE = ?, DESCRIPTION = ? WHERE ID = ?";
    
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:inventory.date];
    
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, inventory.area.areaId);
        sqlite3_bind_text(stmt, 2, [[inventory name] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [[inventory author] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [[inventory description] UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, inventory.inventoryId);
        
        NSLog(@"Update inventory in db: %@", inventory);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %@", inventory);
    }
    
    sqlite3_finalize(stmt);
}

- (void) deleteInventory:(long long int) inventoryId {
    sqlite3_stmt* statement;
    
    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM inventory WHERE ID = '%lld'", inventoryId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Inventory deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
}

- (void) deleteInventories:(NSMutableArray *)inventories {
    
    for (Inventory *inventory in inventories) {
        [self deleteInventory:inventory.inventoryId];
    }
}

- (NSMutableArray *) getInventories {
    // All inventories are stored in here
    NSMutableArray *inventories = [[NSMutableArray alloc] init];
    
    // Get all Areas for right connection between area, inventory and observation objects
    NSMutableArray *areas = [self getAreas];
    
    for (Area *area in areas) {
        [inventories addObjectsFromArray:area.inventories];
    }
    
    return inventories;
}

- (Inventory *) getInventory:(long long int) inventoryId {
    
    Inventory *inventory;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM inventory WHERE ID = '%lld'", inventoryId];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
        
            int areaId = sqlite3_column_int(statement, 1);
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            
            NSString *description;
            
            // Check if description is null
            if(sqlite3_column_text(statement, 5) == NULL) {
                description = @"";
            } else {
                description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            // Create Inventory
            inventory = [[Inventory alloc] init];
            inventory.areaId = areaId;
            inventory.inventoryId = inventoryId;
            inventory.name = name;
            inventory.author = author;
            inventory.date = date;
            inventory.description = description;
            inventory.submitToServer = true;
            inventory.observations = [self getObservationsFromInventory:inventory];
            
        }
        sqlite3_finalize(statement);
    }
    return inventory;
}

- (NSMutableArray *) getObservationsFromInventory:(Inventory *)inventory {
    // All observations are stored in here
    NSMutableArray *observations = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM observation  WHERE INVENTORY_ID = '%lld' ORDER BY DATE DESC", inventory.inventoryId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(dbUser, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int observationId = sqlite3_column_int(statement, 0);
            //int inventoryId = sqlite3_column_int(statement, 1);
            int organismId = sqlite3_column_int(statement, 2);
            int organismGroupId = sqlite3_column_int(statement, 3);
            NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
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
            organism.nameDe = organismNameDe;
            organism.family = organismFamily;
            
            // Split the lat name into two pieces
            NSArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
            
            if([latNames count] == 2) {
                organism.genus = [latNames objectAtIndex:0];
                organism.species = [latNames objectAtIndex:1];
            } else {
                organism.genus = @"";
                organism.species = @"";
            }
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            
            NSString *amountString = [[NSString alloc] initWithFormat:@"%d", amount];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:locationLat longitude:locationLon];
            
            // Create observation
            Observation *observation = [[Observation alloc] init];
            observation.inventory = inventory;
            observation.observationId = observationId;
            observation.organism = organism;
            observation.author = author;
            observation.date = date;
            observation.amount = amountString;
            observation.location = location;
            observation.accuracy = accuracy;
            observation.comment = comment;
            observation.submitToServer = true;
            observation.pictures = [self getObservationImagesFromObservation:observationId];
            
            // Add area to the areas array
            [observations addObject:observation];
		}
        sqlite3_finalize(statement);
    }
    return observations;
}

// ORGANISMGROUPS
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel
{
    //[self authUser];
    NSDate *starttime = [NSDate date];
    NSMutableArray *organismGroups = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT c.classification_id, c.name_de, COUNT(ct.taxon_id), c.position \
                       FROM classification as c \
                       LEFT JOIN classification_taxon as ct ON ct.classification_id = c.classification_id \
                       WHERE (c.parent = %d) AND (ct.display_level = 1 OR ct.display_level is NULL) \
                       GROUP BY c.classification_id, c.name_de ORDER BY c.position", parentId];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dbStatic, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
       
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int classificationId = sqlite3_column_int(statement, 0);
            NSString *groupName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            int groupCount = sqlite3_column_int(statement, 2);
               
            // Create OrganismGroup
            OrganismGroup *organismGroup = [[OrganismGroup alloc] init];
            
            organismGroup.organismGroupId = classificationId;
            organismGroup.name = groupName;
            organismGroup.count = groupCount;
            
            [organismGroups addObject:organismGroup];
		}
           
        sqlite3_finalize(statement);
    } else {
        
    }    
    
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

// ORGANISMS
- (NSMutableArray *) getOrganismsSortByDE:(int) groupId withCustomFilter:(NSString*) filter {
    NSDate *starttime = [NSDate date];
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSMutableString *query;
    if(groupId == 1){
        query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                 FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);
    }
    else {
        query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
                 FROM classification_taxon ct\
                 LEFT JOIN organism o ON o.organism_id=ct.taxon_id"];
        
        //Append Filter to query
        if([filter length] != 0){
            [query appendString:filter];
        }
        else {
            [query appendFormat:@" WHERE ct.classification_id = %i", groupId];
            [query appendFormat:@" ORDER BY name_de "];
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
            
            if([firstSplit count] > 2) {
                NSString *genus = [firstSplit objectAtIndex:0];
                NSString *species = [firstSplit objectAtIndex:1];
                
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

- (NSMutableArray *) getOrganismsSortByLAT:(int) groupId withCustomFilter: (NSString*) filter {
    NSDate *starttime = [NSDate date];
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSMutableString *query;
    if(groupId == 1){
        query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                 FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);
    }
    else {
        query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
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
            
            if([firstSplit count] > 2) {
                NSString *genus = [firstSplit objectAtIndex:0];
                NSString *species = [firstSplit objectAtIndex:1];
                
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
        query = [NSMutableString stringWithFormat:@"SELECT organism_id, inventory_type_id, name_de, name_sc \
                     FROM organism"];
        NSLog( @"Get all organism, group id: %i", groupId);        
    }  
    else {
        query = [NSMutableString stringWithFormat:@"SELECT DISTINCT o.organism_id, o.inventory_type_id, o.name_de AS name_de, o.name_sc \
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
            
            if([firstSplit count] > 2) {
                NSString *genus = [firstSplit objectAtIndex:0];
                NSString *species = [firstSplit objectAtIndex:1];
                
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
    return allOrganisms;
}


@end
