//
//  CollectionAreaObservationsController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 20.06.13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ObservationsOrganismSubmitController.h"
#import "ACollectionController.h"

@interface CollectionAreaObservationsController : ACollectionController <MKMapViewDelegate> {
    
    IBOutlet UITableView *table;
    IBOutlet UIView *areaObservationsView;
    IBOutlet MKMapView *mapView;
    IBOutlet UISegmentedControl *segmentControl;
    int *countObservations;
    NSMutableArray *areaObservationAnnotations;
    NSMutableDictionary *areasToDraw;

    IBOutlet UISegmentedControl *mapSegmentControl;
    
    ObservationsOrganismSubmitController *organismSubmitController;
}

@property (nonatomic) IBOutlet UIView *areaObservationsView;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;

- (IBAction)segmentChanged:(id)sender;
- (IBAction)mapSegmentChanged:(id)sender;
@end
