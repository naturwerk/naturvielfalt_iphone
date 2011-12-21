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

@property (nonatomic, retain) Organism *organism;
@property (nonatomic, retain) IBOutlet UILabel *nameDe;
@property (nonatomic, retain) IBOutlet UILabel *nameLat;
@property (nonatomic, retain) IBOutlet UILabel *family;
@property (nonatomic, retain) IBOutlet UILabel *keyOne;
@property (nonatomic, retain) IBOutlet UILabel *keyTwo;
@property (nonatomic, retain) IBOutlet UILabel *valueOne;
@property (nonatomic, retain) IBOutlet UILabel *valueTwo;
@property (nonatomic, retain) IBOutlet UIButton *wikiButton;
@property (nonatomic, retain) IBOutlet UIImageView *picture;
@property (nonatomic, retain) IBOutlet UILabel *imageAuthor;

- (IBAction) wikipediaLinkClicked;

@end
