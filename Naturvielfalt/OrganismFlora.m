//
//  OrganismFauna.m
//  Naturvielfalt
//
//  Created by Robin Oster on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OrganismFlora.h"

@implementation OrganismFlora
@synthesize isNeophyte;
@synthesize status;

- (void) dealloc 
{
    [super dealloc];    
    
    [status release];
}

@end
