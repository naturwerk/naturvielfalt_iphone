//
//  ObservationImage.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.05.13.
//
//

#import "ObservationImage.h"

@implementation ObservationImage
@synthesize observationId, observationImageId, image;

static ObservationImage *observationImage;

- (ObservationImage *) getObservationImage {
    
    @synchronized(self)
    {
        if (!observationImage) {
            observationImage = [[ObservationImage alloc] init];
        }
        return observationImage;
    }
}

- (void) setObservationImage:(ObservationImage *) obsImg {
    observationImage = obsImg;
}

@end
