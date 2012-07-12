//
//  ObservationsOrganismSubmitController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 11.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"
#import "Observation.h"
#import <CoreLocation/CoreLocation.h>
#import "PersistenceManager.h"

@interface ObservationsOrganismSubmitController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    Organism *__weak organism;
    Observation *__weak observation;
    IBOutlet UILabel *nameDe;
    IBOutlet UILabel *nameLat;
    IBOutlet UILabel *family;
    IBOutlet UITableView *tableView;
    UIImage *accuracyImage;
    NSString *accuracyText;
    CLLocationManager *locationManager;
    
    NSArray *arrayKeys;
    NSArray *arrayValues;
    
    PersistenceManager *persistenceManager;
    
    BOOL review;
    BOOL comeFromOrganism;
    BOOL observationChanged;
}


@property (nonatomic, assign) BOOL observationChanged;
@property (nonatomic, weak) Organism *organism;
@property (nonatomic, weak) Observation *observation;
@property (nonatomic) IBOutlet UILabel *nameDe;
@property (nonatomic) IBOutlet UILabel *nameLat;
@property (nonatomic) IBOutlet UILabel *family;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIImage *accuracyImage;
@property (nonatomic) NSString *accuracyText;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) NSArray *arrayKeys;
@property (nonatomic) NSArray *arrayValues;

@property (nonatomic) PersistenceManager *persistenceManager;

@property (nonatomic, assign) BOOL review;
@property (nonatomic, assign) BOOL comeFromOrganism;

- (void) updateAccuracyIcon:(int)accuracy;
- (void) prepareData;
- (void) rowClicked:(NSIndexPath *)indexPath;
- (void) saveObservation;

@end