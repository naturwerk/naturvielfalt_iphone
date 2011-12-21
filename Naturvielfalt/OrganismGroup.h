//
//  OrganismGroup.h
//  Naturvielfalt
//
//  Created by Robin Oster on 27.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OrganismGroup : NSObject {
    NSInteger organismGroupId;
    NSInteger classlevel;
    NSString *name;
    NSInteger count;
    NSMutableArray *childs;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) NSInteger organismGroupId;
@property(nonatomic, assign) NSInteger classlevel;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSMutableArray *childs;

@end
