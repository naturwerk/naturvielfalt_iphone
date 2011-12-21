//
//  CheckboxCell.m
//  Naturvielfalt
//
//  Created by Robin Oster on 28.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckboxCell.h"
#import "CollectionOverviewController.h"

@implementation CheckboxCell
@synthesize checkbox, name, latName, date, amount, remove;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
