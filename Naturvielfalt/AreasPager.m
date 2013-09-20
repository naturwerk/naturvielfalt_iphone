//
//  AreasPager.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.09.13.
//
//

#import "AreasPager.h"
#import "PersistenceManager.h"

@implementation AreasPager

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // do request on async thread
    dispatch_queue_t fetchQ = dispatch_queue_create("Get Areas", NULL);
    dispatch_async(fetchQ, ^{
        PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
        NSArray *results = [persistenceManager getAreasWithOffset:pageSize * (page-1) andLimit:pageSize withInventories:YES];
        int total = [persistenceManager getAreasCount];
        [persistenceManager closeConnection];
        
        // go back to main thread before adding results
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self receivedResults:results total:total];
        });
    });
    
    
}

@end
