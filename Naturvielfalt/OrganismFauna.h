//
//  OrganismFlora.h
//  Naturvielfalt
//
//  Created by Robin Oster on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Organism.h"

@interface OrganismFauna : Organism {
    NSString *protectionCH;
    NSString *cscfNr;
}

@property (nonatomic) NSString *protectionCH;
@property (nonatomic) NSString *cscfNr;

@end
