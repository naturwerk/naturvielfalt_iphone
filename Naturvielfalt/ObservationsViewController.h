//
//  ObservationsViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"


@interface ObservationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *listData;
    IBOutlet UITableView  *table;
    IBOutlet UIActivityIndicatorView *spinner;
    int groupId;
    int classlevel;
    Observation *observation;
}

@property (nonatomic) NSMutableArray *listData;
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) int groupId;
@property (nonatomic, assign) int classlevel;
@property (nonatomic) Observation *observation;

@end
