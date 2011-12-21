//
//  OrganismFauna.h
//  Naturvielfalt
//
//  Created by Robin Oster on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Organism.h"

@interface OrganismFlora : Organism {
    BOOL *isNeophyte;
    NSString *status;
}

@property (nonatomic, assign) BOOL *isNeophyte;
@property (nonatomic, retain) NSString *status;


@end
