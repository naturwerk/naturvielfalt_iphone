//
//  CollectionOverviewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 Naturwerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceManager.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import <MapKit/MapKit.h>
#import "Listener.h"

@interface CollectionObservationsController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate,MKMapViewDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate, Listener> {
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    NSMutableArray *observationsToSubmit;
    NSMutableArray *observationAnnotations;
    int *countObservations;
    IBOutlet UITableView *table;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *observationsView;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
    int requestCounter;
    NSMutableArray *obsToSubmit;
    NSMutableArray *requests;
    NSMutableArray *asyncDelegates;
    MBProgressHUD *loadingHUD;
}

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic) NSMutableArray *observationsToSubmit;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) ASINetworkQueue *queue;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSIndexPath *curIndex;
@property (nonatomic) BOOL doSubmit;
@property (nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) IBOutlet UIView *observationsView;
@property (nonatomic) NSMutableArray *obsToSubmit;


- (void) sendObservations;
- (void) sendRequestToServer;
- (void) reloadObservations;
- (void) removeObservations;
- (BOOL) connectedToWiFi;
- (void) checkboxEvent:(UIButton *)sender;
- (void) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request;



@end
