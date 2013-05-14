//
//  SettingsViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSMutableArray *titlesSectionOne;
    NSMutableArray *titlesSectionTwo;
    UISegmentedControl *segmentControl;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *titles;


@end
