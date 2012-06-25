//
//  Observation.h
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Organism.h"

@interface Observation : NSObject {
    NSInteger observationId;
    Organism *organism;
    NSString *author;
    NSDate *date;
    NSString *amount;
    CLLocation *location;
    NSInteger accuracy;
    NSMutableArray *pictures;
    NSString *comment;
    BOOL submitToServer;
    BOOL *locationLocked;
}

@property (nonatomic, assign) NSInteger observationId;
@property (nonatomic) Organism *organism;
@property (nonatomic) NSString *author;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *amount;
@property (nonatomic) CLLocation *location;
@property (nonatomic, assign) NSInteger accuracy;
@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSString *comment;
@property (nonatomic, assign) BOOL submitToServer;
@property (nonatomic, assign) BOOL *locationLocked;

- (Observation *) getObservation;
- (void) setObservation:(Observation *)observation;

@end
