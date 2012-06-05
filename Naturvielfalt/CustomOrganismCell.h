//
//  CustomOrganismCell.h
//  Naturvielfalt
//
//  Created by Ramon Gamma on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomOrganismCell : UITableViewCell{
    IBOutlet UIButton *wikiButton;
    IBOutlet UILabel *textLabel;
    IBOutlet UILabel *detailTextLabel;
}


@property (nonatomic) IBOutlet UIButton *wikiButton;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UILabel *detailTextLabel;

@end
