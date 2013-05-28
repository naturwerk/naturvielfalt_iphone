//
//  ObservationsViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inventory.h"
#import "PersistenceManager.h"


@interface ObservationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *listData;
    IBOutlet UITableView  *table;
    IBOutlet UIActivityIndicatorView *spinner;
    int groupId;
    int classlevel;
    
    // It's needed for navigation with area feature
    Inventory *inventory;
    PersistenceManager *persistenceManager;
}

@property (nonatomic) NSMutableArray *listData;
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) int groupId;
@property (nonatomic, assign) int classlevel;
@property (nonatomic) Inventory *inventory;
@property (nonatomic) PersistenceManager *persistenceManager;

@end
