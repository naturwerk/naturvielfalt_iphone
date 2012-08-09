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
    
    if (sqlite3_exec (dbUser, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(dbUser);
        NSAssert1(0, @"Error creating table: %s", errorMsg);
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

- (long long int) saveObservation:(Observation *) observation
{
    char *sql = "INSERT INTO observation (ORGANISM_ID, ORGANISMGROUP_ID, ORGANISM_NAME, ORGANISM_NAME_LAT, ORGANISM_FAMILY, AUTHOR, DATE, AMOUNT, LOCATION_LAT, LOCATION_LON, ACCURACY, COMMENT, IMAGE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *stmt;

    // Create date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:observation.date];
        
    // Put the data into the insert statement
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
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
    
    NSLog(@"Insert observation in db: %@", observation);
    
    char *errorMsg;
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %s", errorMsg);
    }
    
    sqlite3_finalize(stmt);
    
    return sqlite3_last_insert_rowid(dbUser);
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
    if (sqlite3_prepare_v2(dbUser, sql, -1, &stmt, nil) == SQLITE_OK) {
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
        NSLog(@"Update observation in db: %@", observation);
    }
    
    char *errorMsg;
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert1(0, @"Error inserting into table: %s", errorMsg);
    }
    
    sqlite3_finalize(stmt);
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
            observation.observationId = observationId;
            observation.organism = organism;
            observation.author = author;
            observation.date = date;
            observation.amount = amountString;
            observation.location = location;
            observation.accuracy = accuracy;
            observation.comment = comment;
            observation.submitToServer = true;
            observation.pictures = arrayImages;

            
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
    NSString* sqlStatement = [NSString stringWithFormat:@"DELETE FROM observation WHERE ID = '%d'", observationId];
    
    if( sqlite3_prepare_v2(dbUser, [sqlStatement UTF8String], -1, &statement, NULL) == SQLITE_OK ) {
        if( sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Observation deleted!");
        } else {
            NSLog(@"DeleteFromDataBase: Failed from sqlite3_step. Error is:  %s", sqlite3_errmsg(dbUser) );
        }
    } else {
        NSLog( @"DeleteFromDataBase: Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(dbUser) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
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
                if([nameDe length] == 0) nameDe = @"Keine Übersetzung vorhanden";
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

- (NSMutableArray *) getAllOrganisms:(int) groupId
{
    NSMutableArray *allOrganisms;
    allOrganisms =[self getOrganisms:groupId withCustomFilter:@""];
    return allOrganisms;
}

@end
