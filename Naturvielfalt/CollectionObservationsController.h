//
//  CollectionOverviewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 Naturwerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import <MapKit/MapKit.h>
#import "AreaUploadHelper.h"
#import "AlertUploadView.h"
#import "ObservationsOrganismSubmitController.h"
#import "ACollectionController.h"

@interface CollectionObservationsController : ACollectionController <MKMapViewDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate, Listener> {
    NSMutableArray *observationsToSubmit;
    NSMutableArray *observationAnnotations;
    int countObservations;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *observationsView;
    int observationCounter;
    int totalRequests;
    NSMutableArray *obsToSubmit;
    NSMutableArray *observationUploadHelpers;

    IBOutlet UIButton *checkAllButton;
    IBOutlet UISegmentedControl *mapSegmentControl;
    IBOutlet UIImageView *checkAllView;
    ObservationsOrganismSubmitController *organismSubmitController;
}

@property (nonatomic) IBOutlet UIImageView *checkAllView;
@property (nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) NSMutableArray *observationsToSubmit;
@property (nonatomic, assign) int countObservations;
@property (nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) IBOutlet UIView *observationsView;
@property (nonatomic) NSMutableArray *obsToSubmit;
@property (nonatomic) IBOutlet UIButton *checkAllButton;


- (IBAction)mapSegmentChanged:(id)sender;
- (IBAction)checkAllObs:(id)sender;
- (void) sendObservations;
- (void) sendRequestToServer;
- (void) removeObservations;
- (void) checkboxEvent:(UIButton *)sender;
- (IBAction)segmentChanged:(id)sender;


@end
