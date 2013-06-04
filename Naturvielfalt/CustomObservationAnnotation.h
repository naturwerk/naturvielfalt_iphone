//
//  CustomObservationAnnotation.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Observation.h"

@interface CustomObservationAnnotation : NSObject <MKAnnotation> {
    
    NSString *title;
    NSString *subtitle;
    Observation *observation;
}

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo observation:(Observation*)obs;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) Observation *observation;

@end
