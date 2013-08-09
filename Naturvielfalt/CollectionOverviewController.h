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
#import "AlertUploadView.h"

@interface CollectionOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, Listener> {
    PersistenceManager *persistenceManager;
    NSMutableArray *observations;
    NSMutableArray *observationsToSubmit;
    int *countObservations;
    IBOutlet UITableView *table;
    ASINetworkQueue *queue;
    NSOperationQueue *operationQueue;
    NSIndexPath *curIndex;
    BOOL doSubmit;
    int requestCounter;
    int totalRequests;
    NSMutableArray *obsToSubmit;
    NSMutableArray *requests;
    NSMutableArray *asyncDelegates;
    MBProgressHUD *loadingHUD;
    AlertUploadView *uploadView;
    BOOL cancelSubmission;
    IBOutlet UIButton *checkAllButton;
    IBOutlet UIImageView *checkAllView;
    IBOutlet UILabel *noEntryFoundLabel;
}

@property (nonatomic) IBOutlet UILabel *noEntryFoundLabel;
@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NSMutableArray *observations;
@property (nonatomic) NSMutableArray *observationsToSubmit;
@property (nonatomic, assign) int *countObservations;
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) ASINetworkQueue *queue;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSIndexPath *curIndex;
@property (nonatomic) BOOL doSubmit;
@property (nonatomic) IBOutlet UIButton *checkAllButton;
@property (nonatomic) IBOutlet UIImageView *checkAllView;


- (IBAction)checkAllObs:(id)sender;
- (void) sendObservations;
- (void) sendRequestToServer;
- (void) reloadObservations;
- (void) removeObservations;
- (BOOL) connectedToWiFi;
- (void) checkboxEvent:(UIButton *)sender;
- (void) submitData:(Observation *)ob withRequest:(ASIFormDataRequest *)request;


@end
