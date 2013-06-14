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
#import "Listener.h"

@interface CollectionOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, Listener> {
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    NSMutableArray *observationsToSubmit;
    int *countObservations;
    IBOutlet UITableView *table;
    ASINetworkQueue *queue;
    IBOutlet UIProgressView *progressView;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
    int requestCounter;
    NSMutableArray *obsToSubmit;
    NSMutableArray *requests;
    NSMutableArray *asyncDelegates;
    MBProgressHUD *loadingHUD;
}

@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic) NSMutableArray *observationsToSubmit;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) ASINetworkQueue *queue;
@property (nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSIndexPath *curIndex;
@property (nonatomic) BOOL doSubmit;


- (void) sendObservations;
- (void) sendRequestToServer;
- (void) reloadObservations;
- (void) removeObservations;
- (BOOL) connectedToWiFi;
- (void) checkboxEvent:(UIButton *)sender;
- (void) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request;


@end
