//
//  Paginator.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.09.13.
//
//

#import "SingleObservationPager.h"
#import "PersistenceManager.h"

@implementation SingleObservationPager

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // do request on async thread
    dispatch_queue_t fetchQ = dispatch_queue_create("Get Singleobservations", NULL);
    dispatch_async(fetchQ, ^{
        PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
        NSArray *results = [persistenceManager getAllSingelObservationsWithOffset:pageSize * (page-1) andLimit:pageSize];
        int total = [persistenceManager getSingleObservationsCount];
        [persistenceManager closeConnection];
        
        // go back to main thread before adding results
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self receivedResults:results total:total];
        });
    });
    
    
}

@end
