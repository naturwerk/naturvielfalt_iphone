//
//  MKPolyline+MKPolylineCategory.m
//  Naturvielfalt
//
//  This extended version of MKPolyline was needed to hold properties (DrawMode, BOOL).
//  Properties are not supported in Categories. So to hold properties you have to use
//  Object Association, which implementation is in objc/runtime.h. This solution allows
//  to associate objects like a MKPolyline and a boolean.
//
//  Created by Albert von Felten on 24.04.13.
//
//

#import "MKPolyline+MKPolylineCategory.h"
#import <objc/runtime.h>


@implementation MKPolyline (MKPolylineCategory)

static char const * const perstistedTagKey = "persistedLineKey";
static char const * const typeTagKey = "typeLineKey";
static char const * const areaTagKey = "areaLineKey";

- (void) setType:(DrawMode)type {
    NSNumber *number = [NSNumber numberWithInt:type];
    //associate self to number
    objc_setAssociatedObject(self, typeTagKey, number, OBJC_ASSOCIATION_RETAIN);
}

- (DrawMode)type {
    NSNumber *number = objc_getAssociatedObject(self, typeTagKey);
    return [number integerValue];
}

- (void) setPersisted:(BOOL)persisted {
    NSNumber *number = [NSNumber numberWithBool:persisted];
    objc_setAssociatedObject(self, perstistedTagKey, number, OBJC_ASSOCIATION_RETAIN);

}

- (BOOL)persisted {
    NSNumber *number = objc_getAssociatedObject(self, perstistedTagKey);
    return [number boolValue];
}

- (void)setArea:(Area *)area {
    objc_setAssociatedObject(self, areaTagKey, area, OBJC_ASSOCIATION_RETAIN);
}

- (Area*)area {
    return objc_getAssociatedObject(self, areaTagKey);
}

@end
