//
//  Organism.m
//  Naturvielfalt
//
//  Created by Robin Oster on 29.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Organism.h"

extern int UNKNOWN_ORGANISMID;

@implementation Organism
@synthesize organismId, organismGroupId, nameDe, genus, species, family, nameLat, organismGroupName;

-(NSString *)getLatName {
    if (organismId != UNKNOWN_ORGANISMID) {
        if([genus isEqual: @""]){
            if([nameLat isEqual: @""]){
                return NSLocalizedString(@"noLatName", nil);
            }
            return nameLat;
        }
        return [NSString stringWithFormat:@"%@ %@", genus, species];
    } else {
        return NSLocalizedString(@"toBeDetermined", nil);
    }
}

- (NSString *)getNameDe {
    // Only set the german name, genus and species if it exists    
    NSString *nameDeValue = ([nameDe isEqual: @""]) ? nameLat : [nameDe capitalizedString];
    
    return nameDeValue;
}


@end
