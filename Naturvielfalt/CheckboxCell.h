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
    IBOutlet UILabel *amount;;
    IBOutlet UIImageView *image;
}

@property (nonatomic) UIButton *checkbox;
@property (nonatomic) UIButton *remove;
@property (nonatomic) UILabel *name;
@property (nonatomic) UILabel *latName;
@property (nonatomic) UILabel *date;
@property (nonatomic) UILabel *amount;
@property (nonatomic) IBOutlet UIImageView *image;
@end
