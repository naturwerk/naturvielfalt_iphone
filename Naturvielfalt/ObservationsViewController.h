//
//  ObservationsViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ObservationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *listData;
    IBOutlet UITableView  *table;
    IBOutlet UIActivityIndicatorView *spinner;
    int groupId;
    int classlevel;
}

@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) int groupId;
@property (nonatomic, assign) int classlevel;

- (void) loadFromWebsite;


@end
