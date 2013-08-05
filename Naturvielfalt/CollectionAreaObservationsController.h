//
//  CollectionAreaObservationsController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 20.06.13.
//
//

#import <UIKit/UIKit.h>
#import "PersistenceManager.h"
#import "MBProgressHUD.h"
#import <MapKit/MapKit.h>

@interface CollectionAreaObservationsController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, MKMapViewDelegate> {
    
    IBOutlet UITableView *table;
    IBOutlet UIView *areaObservationsView;
    IBOutlet MKMapView *mapView;
    IBOutlet UISegmentedControl *segmentControl;
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    int *countObservations;
    NSIndexPath *curIndex;
    NSMutableArray *areaObservationAnnotations;
    
    NSOperationQueue *operationQueue;
    MBProgressHUD *loadingHUD;
    IBOutlet UISegmentedControl *mapSegmentControl;
}

@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic) NSIndexPath *curIndex;
@property (nonatomic) IBOutlet UIView *areaObservationsView;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;

- (IBAction)segmentChanged:(id)sender;
- (IBAction)mapSegmentChanged:(id)sender;
@end