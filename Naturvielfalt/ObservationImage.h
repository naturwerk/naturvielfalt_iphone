//
//  ObservationImage.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.05.13.
//
//

#import <Foundation/Foundation.h>

@interface ObservationImage : NSObject {
    
    long long int observationImageId;
    long long int observationId;
    UIImage *image;
    BOOL submitted;
}

@property (nonatomic) long long int observationImageId;
@property (nonatomic) long long int observationId;
@property (nonatomic) UIImage *image;
@property (nonatomic) BOOL submitted;

- (ObservationImage *) getObservationImage;
- (void) setObservationImage:(ObservationImage *)obsImg;

@end
