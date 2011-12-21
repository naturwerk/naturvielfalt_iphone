//
//  CheckboxCell.h
//  Naturvielfalt
//
//  Created by Robin Oster on 28.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckboxCell : UITableViewCell {
    IBOutlet UIButton *checkbox;
    IBOutlet UIButton *remove;
    IBOutlet UILabel *name;
    IBOutlet UILabel *latName;
    IBOutlet UILabel *date;
    IBOutlet UILabel *amount;
}

@property (nonatomic, retain) UIButton *checkbox;
@property (nonatomic, retain) UIButton *remove;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *latName;
@property (nonatomic, retain) UILabel *date;
@property (nonatomic, retain) UILabel *amount;

@end
