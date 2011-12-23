//
//  Organism.m
//  Naturvielfalt
//
//  Created by Robin Oster on 29.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Organism.h"

@implementation Organism
@synthesize organismId, organismGroupId, nameDe, genus, species, family, nameLat;

-(NSString *)getLatName {
    
    NSString *gen = (genus == nil || genus == (id)[NSNull null]) ? @"Kein" : [genus capitalizedString];
    NSString *spec = (species == nil || species == (id)[NSNull null]) ? @"lateinischer Name" : species;
    
    NSString *lat = [NSString stringWithFormat:@"%@ %@", gen, spec];
    
    return lat;
}

- (NSString *)getNameDe {
    // Only set the german name, genus and species if it exists    
    NSString *nameDeValue = (nameDe == nil || nameDe == (id)[NSNull null] || [nameDe length] == 0) ? nameLat : [nameDe capitalizedString];
    
    return nameDeValue;
}

- (void) dealloc 
{
    [super dealloc];
    
    [nameDe release];
    [genus release];
    [species release];
    [family release];
}

@end
