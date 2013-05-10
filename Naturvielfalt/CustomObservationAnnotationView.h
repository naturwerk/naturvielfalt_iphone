//
//  CustomObservationAnnotationView.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import <MapKit/MapKit.h>
#import "CustomObservationAnnotation.h"
#import "ObservationsOrganismSubmitController.h"

@interface CustomObservationAnnotationView : MKPinAnnotationView {
    
    CustomObservationAnnotation *observationAnnotation;
    ObservationsOrganismSubmitController *organismSubmitController;
    UINavigationController *navigationController;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation navigationController:(UINavigationController*)nc observationsOrganismSubmitController:(ObservationsOrganismSubmitController*)oc reuseIdentifier:(NSString *)reuseIdentifier;

@end
