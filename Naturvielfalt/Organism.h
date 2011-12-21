//
//  Organism.h
//  Naturvielfalt
//
//  Created by Robin Oster on 29.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Organism : NSObject {
    NSInteger organismId;
    NSInteger organismGroupId;
    NSString *nameDe;
    NSString *genus;
    NSString *species;
    NSString *family;
    NSString *nameLat;
}

@property (nonatomic, assign) NSInteger organismId;
@property (nonatomic, assign) NSInteger organismGroupId;
@property (nonatomic, retain) NSString *nameDe;
@property (nonatomic, retain) NSString *genus;
@property (nonatomic, retain) NSString *species;
@property (nonatomic, retain) NSString *family;
@property (nonatomic, retain) NSString *nameLat;

- (NSString *) getLatName;
- (NSString *) getNameDe;

@end
