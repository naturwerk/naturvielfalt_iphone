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
    
    DrawMode areaType;
    NSString *title;
    NSString *subtitle;
    Observation *observation;
}

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo type:(DrawMode)type observation:(Observation*)obs;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) Observation *observation;
@property (nonatomic) DrawMode areaType;

@end
