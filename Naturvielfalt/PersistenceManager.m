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

@implementation PersistenceManager
@synthesize database;


- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0] ;
    
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

// CONNECTION
- (void) establishConnection
{
    NSString *fileName = @"db.sqlite3";
    NSString *dbFilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), fileName];
    
    NSFileManager *fmngr = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError *error;
    
    if(![fmngr fileExistsAtPath:dbFilePath]) {
        if(![fmngr copyItemAtPath:filePath toPath:dbFilePath error:&error]) {
            // handle the error
            NSLog(@"Error creating the database: %@", [error description]);
        } else {
            NSLog(@"DB file successfully copied");
        }
    }
    
    [fmngr release];
    
    
    // Create link to database
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
	
    // Create TABLE (At the moment IMAGE BLOB is missing..)
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS observation (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
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
                                                                     COMMENT TEXT,                         \
                                                                     IMAGE BLOB);";
    
    char *errorMsg;
    
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating table: %s", errorMsg);
    }
}

- (void) closeConnection
{
    // Disconnect link to database
    sqlite3_close(database);
}

- (int *) saveObservation:(Observation *) observation
{
    char *sql = "INSERT INTO observation (ORGANISM_ID, ORGANISMGROUP_ID, ORGANISM_NAME, ORGANISM_NAME_LAT, ORGANISM_FAMILY, AUTHOR, DATE, AMOUNT, LOCATION_LAT, LOCATION_LON, ACCURACY, COMMENT, IMAGE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *stmt;

    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:observation.date];
        
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, observation.organism.organismId);
        sqlite3_bind_int(stmt, 2, observation.organism.organismGroupId);
        sqlite3_bind_text(stmt, 3, [[observation.organism getNameDe] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [[observation.organism getLatName] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [observation.organism.family UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [observation.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 8, [observation.amount intValue]);
        sqlite3_bind_double(stmt, 9, observation.location.coordinate.latitude);
        sqlite3_bind_double(stmt, 10, observation.location.coordinate.longitude);
        sqlite3_bind_int(stmt, 11, observation.accuracy);
        sqlite3_bind_text(stmt, 12, [observation.comment UTF8String], -1, NULL);
        
        // Check if there are any images
        if(observation.pictures.count > 0) {
            UIImage *image = [observation.pictures objectAtIndex:0];
            NSData *imageData = UIImagePNGRepresentation(image);
            
            sqlite3_bind_blob(stmt, 13, [imageData bytes] , [imageData length], NULL);
        } else {
            sqlite3_bind_blob(stmt, 13, nil , -1, NULL);
        }
    }
    
    NSLog(@"SUUUUBMIIIIT: %@", observation);
    
    char *errorMsg;
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %s", errorMsg);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(database);
}




// OBSERVATIONS
- (void) updateObservation:(Observation *) observation
{
    char *sql = "UPDATE observation SET ORGANISM_ID = ?, ORGANISMGROUP_ID = ?, ORGANISM_NAME = ?, ORGANISM_NAME_LAT = ?, ORGANISM_FAMILY = ?, AUTHOR = ?, DATE = ?, AMOUNT = ?, LOCATION_LAT = ?, LOCATION_LON = ?, ACCURACY = ?, COMMENT = ?, IMAGE = ? WHERE ID = ?";
    
    sqlite3_stmt *stmt;
    
    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:observation.date];
 
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, observation.organism.organismId);
        sqlite3_bind_int(stmt, 2, observation.organism.organismGroupId);
        sqlite3_bind_text(stmt, 3, [[observation.organism getNameDe] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [[observation.organism getLatName] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [observation.organism.family UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [observation.author UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [formattedDate UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 8, [observation.amount intValue]);
        sqlite3_bind_double(stmt, 9, observation.location.coordinate.latitude);
        sqlite3_bind_double(stmt, 10, observation.location.coordinate.longitude);
        sqlite3_bind_int(stmt, 11, observation.accuracy);
        sqlite3_bind_text(stmt, 12, [observation.comment UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 14, observation.observationId);
        
        // Check if there are any images
        if(observation.pictures.count > 0) {
            UIImage *image = [observation.pictures objectAtIndex:0];
            NSData *imageData = UIImagePNGRepresentation(image);
            
            sqlite3_bind_blob(stmt, 13, [imageData bytes] , [imageData length], NULL);
        } else {
            sqlite3_bind_blob(stmt, 13, nil , -1, NULL);
        }
    }
    
    char *errorMsg;
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %s", errorMsg);
    }
    
    sqlite3_finalize(stmt);
}


- (NSMutableArray *) getObservations
{
    NSTimeInterval timestampStart = [[NSDate date] timeIntervalSince1970];
    
    // All observations are stored in here
    NSMutableArray *observations = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM observation";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int observationId = sqlite3_column_int(statement, 0);
            int organismId = sqlite3_column_int(statement, 1);
            int organismGroupId = sqlite3_column_int(statement, 2);
            NSString *organismNameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *organismNameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            NSString *author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            NSString *dateString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
            int amount = sqlite3_column_int(statement, 8);
            double locationLat = sqlite3_column_double(statement, 9);
            double locationLon = sqlite3_column_double(statement, 10);
            int accuracy = sqlite3_column_int(statement, 11);
            NSString *comment;
            NSString *organismFamily;
            
            
            // Check if the comment is null
            if(sqlite3_column_text(statement, 5) == NULL) {
                organismFamily = @"";
            } else {
                organismFamily = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            }
            
            // Check if the comment is null
            if(sqlite3_column_text(statement, 12) == NULL) {
                comment = @"";
            } else {
               comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
            }
            
            // Get the image
            NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 13) length:sqlite3_column_bytes(statement, 13)];
            
            NSMutableArray *arrayImages = [[NSMutableArray alloc] init];
            
            if(data != nil) {
                UIImage *image = [UIImage imageWithData:data];
                
                if(image != nil) {
                    [arrayImages addObject:image];
                }
            }
                        
            // Create organism and set the id
            Organism *organism = [[Organism alloc] init];
            organism.organismId = organismId;
            organism.organismGroupId = organismGroupId;
            organism.nameDe = organismNameDe;
            organism.family = organismFamily;

            // Split the lat name into two pieces
            NSMutableArray *latNames = [organismNameLat componentsSeparatedByString:@" "];
            
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
  
            // Create observation
            Observation *observation = [[Observation alloc] init];
            observation.observationId = observationId;
            observation.organism = organism;
            observation.author = author;
            observation.date = date;
            observation.amount = amountString;
            observation.location = [[CLLocation alloc] initWithLatitude:locationLat longitude:locationLon];
            observation.accuracy = accuracy;
            observation.comment = comment;
            observation.submitToServer = true;
            observation.pictures = arrayImages;

            
            // Add observation to the observation array
            [observations addObject:observation];

            // NSLog(@"%d %d %@ %@ %@ %d %d %@ %f %f %d", observationId, organismId, organismNameDe, author, date, amount, accuracy, comment, locationLat, locationLon, accuracy);
		}
        
        sqlite3_finalize(statement);
    }
    
    return observations;
}

- (void) deleteObservation:(int)observationId
{
    sqlite3_stmt* statement;

    // Create Query String.
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM observation WHERE ID = '%d'", observationId];
    
    if( sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Observation deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(database) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
}    


// ORGANISMGROUPS
- (NSMutableArray *) getAllOrganismGroups:(int) parentId withClasslevel:(int) classlevel
{
    NSMutableArray *organismGroups = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT c.classification_id, c.class_level, c.name_de, COUNT(ct.taxon_id) \
                        FROM classification as c \
                        LEFT JOIN classification_taxon as ct ON ct.classification_id = c.classification_id \
                        WHERE (c.parent = %d AND c.class_level = %d) AND (ct.display_level = 1 OR ct.display_level is NULL) \
                        GROUP BY c.classification_id, c.class_level, c.name_de ORDER BY c.position", parentId, classlevel];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
            int classificationId = sqlite3_column_int(statement, 0);
            int classLevel = sqlite3_column_int(statement, 1);
            NSString *groupName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            int groupCount = sqlite3_column_int(statement, 3);
               
            // Create OrganismGroup
            OrganismGroup *organismGroup = [[OrganismGroup alloc] init];
            
            organismGroup.organismGroupId = classificationId;
            organismGroup.name = groupName;
            organismGroup.count = groupCount;
            
            [organismGroups addObject:organismGroup];
		}
           
        sqlite3_finalize(statement);
    }
    
    return organismGroups;
}

- (BOOL) organismGroupHasChild:(int) groupId {
    
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM classification WHERE parent = %d", groupId];
    
    sqlite3_stmt *statement;

    int count = 0;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		sqlite3_step(statement);		
        count = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
    }
    
    return (count > 0);
}

// ORGANISMS
- (NSMutableArray *) getAllOrganisms:(int) groupId
{
    NSMutableArray *organisms = [[NSMutableArray alloc] init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT ct.taxon_id, o.inventory_type_id, o.name_de, o.name_sc FROM organism AS o \
                       LEFT JOIN classification_taxon as ct ON ct.taxon_id = o.id \
                       LEFT JOIN classification as c ON c.classification_id = ct.classification_id \
                       WHERE c.classification_id = %d", groupId];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
		while (sqlite3_step(statement) == SQLITE_ROW) {

            int organismId = sqlite3_column_int(statement, 0);
            int organismGroupId = sqlite3_column_int(statement, 1);
            
            NSString *nameDe;
            NSString *nameLat;
            
            if(sqlite3_column_text(statement, 2) == NULL) {
                nameDe = [NSString stringWithString:@""];
            } else {
                nameDe = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            }
            
            if(sqlite3_column_text(statement, 3) == NULL) {
                nameLat = [NSString stringWithString:@""];
            } else {
                nameLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            }
            
            // Create OrganismGroup
            Organism *organism = [[Organism alloc] init];
            
            organism.organismId = organismId;
            organism.organismGroupId = organismGroupId;
            organism.nameDe = nameDe;
            organism.nameLat = nameLat;
            
            // Split into species, genus
            NSArray *firstSplit = [nameLat componentsSeparatedByString:@" "];
            
            if([firstSplit count] > 2) {
                NSString *genus = [firstSplit objectAtIndex:0];
                NSString *species = [firstSplit objectAtIndex:1];
                
                organism.genus = genus;
                organism.species = species;
            }
            
            [organisms addObject:organism];
		}
        
        sqlite3_finalize(statement);
    } else {
        NSLog( @"Get organisms: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database));
    }
    
    return organisms;
}

@end
