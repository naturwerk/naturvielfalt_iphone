//
//  AreaObservationsPager.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.09.13.
//
//

#import "AreaObservationsPager.h"
#import "PersistenceManager.h"

@implementation AreaObservationsPager

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // do request on async thread
    dispatch_queue_t fetchQ = dispatch_queue_create("Get Areaobservations", NULL);
    dispatch_async(fetchQ, ^{
        PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
        [persistenceManager establishConnection];
        NSArray *results = [persistenceManager getAllAreaObservationsWithOffset:pageSize * (page-1) andLimit:pageSize];
        int total = [persistenceManager getAreaObservationsCount];
        [persistenceManager closeConnection];
        
        // go back to main thread before adding results
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self receivedResults:results total:total];
        });
    });
    
    
}
@end
