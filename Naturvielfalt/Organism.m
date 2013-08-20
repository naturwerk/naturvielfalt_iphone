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
@synthesize organismId, organismGroupId, nameDe, nameEn, nameFr, nameIt, genus, species, family, nameLat, organismGroupName;

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

- (NSString *)getName {
    
    NSString *name;
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    NSString *curLanguage =[appSettings stringForKey:@"language"];
    
    // Only set the german name, genus and species if it exists 
    if ([curLanguage isEqualToString:@"de"]) {
        name = ([nameDe isEqual: @""]) ? nameLat : [nameDe capitalizedString];
    } else if ([curLanguage isEqualToString:@"fr"]) {
       name = ([nameFr isEqual: @""]) ? nameLat : [nameFr capitalizedString];
    } else if ([curLanguage isEqualToString:@"en"]) {
       name = ([nameEn isEqual: @""]) ? nameLat : [nameEn capitalizedString];
    } else if ([curLanguage isEqualToString:@"it"]) {
       name = ([nameIt isEqual: @""]) ? nameLat : [nameIt capitalizedString];
    } else {
        name = ([nameEn isEqual: @""]) ? nameLat : [nameEn capitalizedString];
    }
    
    return name;
}


@end
