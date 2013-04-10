//
//  Area.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 04.04.13.
//
//

#import "Area.h"

@implementation Area
@synthesize areaId, author, areaName, inventoryName, date, pictures, description, submitToServer, locationLocked, typeOfArea;

- (id) init {
    
    if (self = [super init]) {
        areaId = 1;
        author = @"Hans Muster";
        areaName = @"Area 1";
        inventoryName = @"Inventory 1";
        date = [[NSDate alloc] initWithTimeIntervalSinceNow:NSTimeIntervalSince1970];
        pictures = nil;
        description = @"Description 1";
        typeOfArea = LINE;
    }
    return self;
}


- (Area *) getArea {
    return self;
}

- (void)setArea:(Area *)area {
    
}

@end
