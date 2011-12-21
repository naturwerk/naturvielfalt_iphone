//
//  OrganismGroup.m
//  Naturvielfalt
//
//  Created by Robin Oster on 27.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrganismGroup.h"


@implementation OrganismGroup
@synthesize name, count, organismGroupId, classlevel, childs;

- (void) dealloc {
    [super dealloc];
    
    [name release];
}

@end
