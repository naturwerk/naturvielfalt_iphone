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
    NSMutableArray *__weak childs;
}

@property(nonatomic) NSString *name;
@property(nonatomic, assign) NSInteger organismGroupId;
@property(nonatomic, assign) NSInteger classlevel;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, weak) NSMutableArray *childs;

@end
