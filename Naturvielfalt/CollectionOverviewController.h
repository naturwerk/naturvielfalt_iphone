//
//  CollectionOverviewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 Naturwerk. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CollectionOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *table;
    NSArray *arrayKeys;
}

@property (nonatomic) IBOutlet UITableView *table;




@end
