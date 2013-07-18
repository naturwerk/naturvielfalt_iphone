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
    NSString *organismGroupName;
}

@property (nonatomic, assign) NSInteger organismId;
@property (nonatomic, assign) NSInteger organismGroupId;
@property (nonatomic) NSString *nameDe;
@property (nonatomic) NSString *genus;
@property (nonatomic) NSString *species;
@property (nonatomic) NSString *family;
@property (nonatomic) NSString *nameLat;
@property (nonatomic) NSString *organismGroupName;

- (NSString *) getLatName;
- (NSString *) getNameDe;

@end
