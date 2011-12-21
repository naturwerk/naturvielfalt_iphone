//
//  StateTableCellView.m
//  States
//
//  Created by Julio Barros on 1/26/09.
//  Copyright 2009 E-String Technologies, Inc.. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

@synthesize key;
@synthesize value;
@synthesize image;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [key release];
    [value release];
    [image release];
    
    [super dealloc];
}


@end
