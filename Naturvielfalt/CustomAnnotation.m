//
//  CustomAnnotation.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 18.04.13.
//
//

#import "CustomAnnotation.h"
#import "Area.h"

@implementation CustomAnnotation
@synthesize annotationType, persisted, coordinate = _coordinate, title, subtitle;

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo type:(DrawMode)type{
    
    if(self = [super init]) {
        persisted = NO;
        annotationType = type;
        _coordinate = coo;
    }
    return self;
}

@end
