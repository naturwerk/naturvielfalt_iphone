//
//  AreasSubmitMapController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.04.13.
//  Copyright (c) 2013 Naturwerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceManager.h"
#import "CustomAnnotation.h"

@class AreasViewController;
@interface AreasSubmitController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    Area *area;
    PersistenceManager *persistenceManager;
    NSArray *arrayKeys;
    NSArray *arrayValues;
    DrawMode drawMode;
    CustomAnnotation *customAnnotation;
    AreasViewController *areasViewController;
    
    BOOL review;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, assign) BOOL areaChanged;
@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) DrawMode drawMode;
@property (nonatomic) CustomAnnotation *customAnnotation;


- (void) prepareData;
- (void) rowClicked:(NSIndexPath *)indexPath;
- (void) saveArea;

@end
