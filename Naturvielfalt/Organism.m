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
    
    if([genus isEqual: @""]){
        if([nameLat isEqual: @""]){
            return @"Kein lateinischer Name";
        }
        return nameLat;
    }
    return [NSString stringWithFormat:@"%@ %@", genus, species];
}

- (NSString *)getNameDe {
    // Only set the german name, genus and species if it exists    
    NSString *nameDeValue = ([nameDe isEqual: @""]) ? nameLat : [nameDe capitalizedString];
    
    return nameDeValue;
}


@end
