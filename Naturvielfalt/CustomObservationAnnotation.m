//
//  CustomObservationAnnotation.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import "CustomObservationAnnotation.h"

@implementation CustomObservationAnnotation
@synthesize title, subtitle, observation, coordinate = _coordinate, areaType;

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo type:(DrawMode)type observation:(Observation*)obs {
    
    if(self = [super init]) {
        areaType = type;
        _coordinate = coo;
        observation = obs;
    }
    return self;
}

- (NSString*)title {
    return observation.organism.nameDe;
}

- (NSString*)subtitle {
    return observation.organism.species;
}

@end
