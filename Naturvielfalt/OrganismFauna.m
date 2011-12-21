//
//  OrganismFlora.m
//  Naturvielfalt
//
//  Created by Robin Oster on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OrganismFauna.h"

@implementation OrganismFauna
@synthesize protectionCH;
@synthesize cscfNr;


- (void) dealloc 
{
    [super dealloc];
    
    [protectionCH release];
    [cscfNr release];
}

@end
