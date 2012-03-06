//
//  ObservationsOrganismDetailViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 12.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"

@interface ObservationsOrganismDetailViewController : UIViewController { 
    Organism *organism;
    IBOutlet UILabel *nameDe;
    IBOutlet UILabel *nameLat;
    IBOutlet UILabel *family;
    IBOutlet UILabel *keyOne;
    IBOutlet UILabel *keyTwo;
    IBOutlet UILabel *valueOne;
    IBOutlet UILabel *valueTwo;
    IBOutlet UIButton *wikiButton;
    IBOutlet UIImageView *picture;
    IBOutlet UILabel *imageAuthor;
}

@property (nonatomic) Organism *organism;
@property (nonatomic) IBOutlet UILabel *nameDe;
@property (nonatomic) IBOutlet UILabel *nameLat;
@property (nonatomic) IBOutlet UILabel *family;
@property (nonatomic) IBOutlet UILabel *keyOne;
@property (nonatomic) IBOutlet UILabel *keyTwo;
@property (nonatomic) IBOutlet UILabel *valueOne;
@property (nonatomic) IBOutlet UILabel *valueTwo;
@property (nonatomic) IBOutlet UIButton *wikiButton;
@property (nonatomic) IBOutlet UIImageView *picture;
@property (nonatomic) IBOutlet UILabel *imageAuthor;

- (IBAction) wikipediaLinkClicked;

@end
