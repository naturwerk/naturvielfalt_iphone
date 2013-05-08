//
//  CustomObservationAnnotationView.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import <MapKit/MapKit.h>
#import "CustomObservationAnnotation.h"

@interface CustomObservationAnnotationView : MKPinAnnotationView {
    
    CustomObservationAnnotation *observationAnnotation;
}

@end
