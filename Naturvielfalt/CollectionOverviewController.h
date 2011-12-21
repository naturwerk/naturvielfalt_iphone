//
//  CollectionOverviewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceManager.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

@interface CollectionOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    NSMutableArray *observationsToSubmit;
    int *countObservations;
    IBOutlet UITableView *table;
    ASINetworkQueue *queue;
    IBOutlet UIProgressView *progressView;
}

@property (nonatomic, retain) PersistenceManager *persistenceManager;
@property (nonatomic, retain) NSMutableArray *observations;
@property (nonatomic, retain) NSMutableArray *observationsToSubmit;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) ASINetworkQueue *queue;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;


- (void) sendObservations;
- (void) sendRequestToServer;
- (void) reloadObservations;
- (void) removeObservations;
- (void) checkboxEvent:(UIButton *)sender;
- (BOOL) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request withPersistenceManager:(PersistenceManager *)persistenceManager;


@end
