//
//  Observation.m
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Observation.h"

@implementation Observation
@synthesize observationId, inventoryId, organism, author, amount, comment, date, location, accuracy, pictures, submitToServer, locationLocked, inventory, guid;


static Observation *observation;

- (Observation *) getObservation
{
    @synchronized(self)
    {
        if (!observation) {
            pictures = [[NSMutableArray alloc] init];
            observation = [[Observation alloc] init];
            observation.locationLocked = false;
            observation.amount = @"1";
            observation.accuracy = 0;
            observation.comment = @"";
            observation.pictures = pictures;
            observation.guid = 0;
        }
    
        return observation;
    }
}

- (void) setObservation:(Observation *)ob
{
    observation = ob;
}

- (NSString *) description
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *output = [[NSString alloc] initWithFormat:@"[%lld] _%d_ %d %@ %@ %@ %@ (%f, %f) #Pics: %d", 
                                                        observationId,
                                                        organism.organismId,
                                                        organism.organismGroupId,
                                                        organism.nameDe,
                                                        author, 
                                                        dateString, 
                                                        amount,
                                                        location.coordinate.latitude, 
                                                        location.coordinate.longitude, 
                                                        [pictures count]];
                        
    return output;
}


@end
