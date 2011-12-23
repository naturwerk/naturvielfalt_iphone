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
    Organism *organism;
    Observation *observation;
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
}

@property (nonatomic, assign) Organism *organism;
@property (nonatomic, assign) Observation *observation;
@property (nonatomic, retain) IBOutlet UILabel *nameDe;
@property (nonatomic, retain) IBOutlet UILabel *nameLat;
@property (nonatomic, retain) IBOutlet UILabel *family;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIImage *accuracyImage;
@property (nonatomic, retain) NSString *accuracyText;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, assign) NSArray *arrayKeys;
@property (nonatomic, assign) NSArray *arrayValues;

@property (nonatomic, retain) PersistenceManager *persistenceManager;

@property (nonatomic, assign) BOOL review;

- (void) updateAccuracyIcon:(int)accuracy;
- (void) prepareData;
- (void) discardLocationManager;
- (void) rowClicked:(NSIndexPath *)indexPath;

@end