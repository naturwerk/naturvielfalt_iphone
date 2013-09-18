//
//  CustomObservationAnnotation.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import "CustomObservationAnnotation.h"

@implementation CustomObservationAnnotation
@synthesize title, subtitle, observation, coordinate = _coordinate;

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo observation:(Observation*)obs {
    
    if(self = [super init]) {
        _coordinate = coo;
        observation = obs;
    }
    return self;
}

- (NSString*)title {
    return [observation.organism getName];
}

- (NSString*)subtitle {
    return observation.organism.species;
}

@end
