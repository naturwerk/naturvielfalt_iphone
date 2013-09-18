//
//  CollectionOverviewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 Naturwerk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CollectionObservationsController.h"
#import "CollectionAreaObservationsController.h"
#import "CollectionInventoriesController.h"
#import "CollectionAreasController.h"

@interface CollectionOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *table;
    NSArray *arrayKeys;
    //Collections view controllers
    CollectionObservationsController *observationsController;
    CollectionAreaObservationsController *areaObservationsController;
    CollectionInventoriesController *inventoriesController;
    CollectionAreasController *areasController;
}

@property (nonatomic) IBOutlet UITableView *table;




@end
